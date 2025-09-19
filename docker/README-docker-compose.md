# Valhalla Docker Compose Setup

This Docker Compose configuration provides a complete Valhalla routing service setup with optional monitoring and reverse proxy capabilities.

## Quick Start

### Basic Setup (Using Pre-built Image)

1. **Create data directories:**
   ```bash
   mkdir -p data gtfs_feeds
   ```

2. **Start Valhalla service:**
   ```bash
   docker-compose up -d
   ```

3. **Check service status:**
   ```bash
   docker-compose ps
   curl http://localhost:8002/status
   ```

### Building from Source

If you want to build Valhalla from source instead of using the pre-built image:

```bash
docker-compose -f docker-compose.yaml -f docker-compose.override.yaml up --build
```

### With Custom OSM Data

1. **Download OSM data:**
   ```bash
   cd data
   wget https://download.geofabrik.de/europe/andorra-latest.osm.pbf
   ```

2. **Update environment variables in docker-compose.yaml:**
   ```yaml
   environment:
     - tile_urls=https://download.geofabrik.de/europe/andorra-latest.osm.pbf
   ```

3. **Restart the service:**
   ```bash
   docker-compose restart valhalla
   ```

## Services

### Core Services

- **valhalla**: Main Valhalla routing service
  - Port: 8002
  - Volume: `./data:/custom_files`
  - Environment variables for configuration

### Optional Services

- **nginx**: Reverse proxy with rate limiting
  - Ports: 80, 443
  - Profile: `production`
  - Start with: `docker-compose --profile production up -d`

- **prometheus**: Metrics collection
  - Port: 9090
  - Profile: `monitoring`
  - Start with: `docker-compose --profile monitoring up -d`

- **grafana**: Metrics visualization
  - Port: 3000
  - Profile: `monitoring`
  - Start with: `docker-compose --profile monitoring up -d`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `tile_urls` | `https://download.geofabrik.de/europe/andorra-latest.osm.pbf` | OSM PBF file URLs (space-separated) |
| `use_tiles_ignore_pbf` | `True` | Use existing tiles.tar if available |
| `build_tar` | `True` | Create tiles.tar for faster loading |
| `serve_tiles` | `True` | Start the Valhalla service |
| `force_rebuild` | `False` | Force rebuild of tiles |
| `build_admins` | `True` | Build admin database |
| `build_time_zones` | `True` | Build timezone database |
| `build_elevation` | `False` | Download elevation tiles |
| `build_transit` | `False` | Build transit tiles |
| `server_threads` | `4` | Number of service threads |
| `tileset_name` | `valhalla_tiles` | Name of the tileset |
| `traffic_name` | `""` | Name of traffic archive |

## Usage Examples

### Basic Routing

```bash
# Test routing
curl -X POST http://localhost:8002/route \
  -H "Content-Type: application/json" \
  -d '{
    "locations": [
      {"lat": 42.5063, "lon": 1.5218},
      {"lat": 42.5078, "lon": 1.5219}
    ],
    "costing": "auto"
  }'
```

### Isochrone Generation

```bash
# Generate isochrone
curl -X POST http://localhost:8002/isochrone \
  -H "Content-Type: application/json" \
  -d '{
    "locations": [{"lat": 42.5063, "lon": 1.5218}],
    "costing": "auto",
    "contours": [{"time": 15}]
  }'
```

### Matrix Calculation

```bash
# Calculate distance matrix
curl -X POST http://localhost:8002/matrix \
  -H "Content-Type: application/json" \
  -d '{
    "sources": [{"lat": 42.5063, "lon": 1.5218}],
    "targets": [{"lat": 42.5078, "lon": 1.5219}],
    "costing": "auto"
  }'
```

## Advanced Configuration

### Custom Configuration

1. **Edit valhalla.json:**
   ```bash
   # The config file will be created automatically
   # You can edit it after the first run
   vim data/valhalla.json
   ```

2. **Restart service:**
   ```bash
   docker-compose restart valhalla
   ```

### Transit Support

1. **Add GTFS feeds:**
   ```bash
   mkdir -p gtfs_feeds/berlin
   # Add GTFS files to gtfs_feeds/berlin/
   ```

2. **Enable transit:**
   ```yaml
   environment:
     - build_transit=True
   ```

3. **Restart service:**
   ```bash
   docker-compose restart valhalla
   ```

### Elevation Data

1. **Add elevation tiles:**
   ```bash
   mkdir -p data/elevation_data/N42
   # Add HGT files like N42E001.hgt
   ```

2. **Enable elevation:**
   ```yaml
   environment:
     - build_elevation=True
   ```

3. **Restart service:**
   ```bash
   docker-compose restart valhalla
   ```

## Monitoring

### With Prometheus and Grafana

1. **Start monitoring stack:**
   ```bash
   docker-compose --profile monitoring up -d
   ```

2. **Access services:**
   - Grafana: http://localhost:3000 (admin/admin)
   - Prometheus: http://localhost:9090

### Health Checks

```bash
# Check service health
curl http://localhost:8002/status

# Check with nginx
curl http://localhost/health
```

## Production Deployment

### With Nginx Reverse Proxy

1. **Start with nginx:**
   ```bash
   docker-compose --profile production up -d
   ```

2. **Configure SSL (optional):**
   - Add SSL certificates to `nginx/ssl/`
   - Uncomment HTTPS configuration in `nginx/nginx.conf`

### Scaling

```yaml
# Scale valhalla service
docker-compose up -d --scale valhalla=3
```

## Troubleshooting

### View Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs valhalla

# Follow logs
docker-compose logs -f valhalla
```

### Debug Mode

```yaml
environment:
  - force_rebuild=True
  - server_threads=1
```

### Common Issues

1. **Out of memory during tile building:**
   - Reduce `server_threads`
   - Increase Docker memory limits

2. **Slow tile building:**
   - Increase `server_threads` (if memory allows)
   - Use faster storage (SSD)

3. **Service not responding:**
   - Check logs: `docker-compose logs valhalla`
   - Verify data directory permissions
   - Check if tiles are being built

## File Structure

```
docker/
├── docker-compose.yaml          # Main compose file
├── nginx/
│   └── nginx.conf              # Nginx configuration
├── monitoring/
│   ├── prometheus.yml          # Prometheus config
│   └── grafana/
│       ├── dashboards/         # Grafana dashboards
│       └── datasources/        # Grafana datasources
└── README-docker-compose.md    # This file
```

## Data Persistence

All Valhalla data is stored in the `./data` directory:
- `valhalla_tiles/` - Routing tiles
- `valhalla_tiles.tar` - Compressed tiles
- `valhalla.json` - Configuration
- `admins.sqlite` - Admin boundaries
- `timezones.sqlite` - Timezone data
- `elevation_data/` - Elevation tiles (if enabled)
