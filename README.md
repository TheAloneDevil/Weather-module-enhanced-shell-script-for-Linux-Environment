# Enhanced Weather Module for Linux Desktop

This package provides an enhanced weather module for Linux desktop using NetworkManager.

## What Does This Do?

This provides a weather display module that shows:
- Current temperature
- Weather conditions with icons
- Moon phase detection (full moon indicator)
- Works with polybar, waybar, and similar

## Files Included

1. **weather.sh** - Main weather script
2. **user_modules.ini** - Module configuration
3. **README.md** - This file

---

## Features

- Fetches weather data from OpenWeatherMap API
- Custom weather icons
- Moon phase detection (shows special icon during full moon)
- 30-minute update interval
- Caching to reduce API calls
- Temperature-based color coding

---

## Installation

### Step 1: Create Directory

mkdir -p ~/YourPath

### Step 2: Copy Files

cp weather.sh ~/YourPath/
cp user_modules.ini ~/YourPath/

### Step 3: Make Executable

chmod +x ~/YourPath/weather.sh

### Step 4: Configure API Key

Edit weather.sh:
- Get CITY_ID from https://openweathermap.org/cities
- Get API_KEY from https://home.openweathermap.org/api_keys (create new one)

Update these lines:
```bash
CITY_ID="1234567"  # Your city ID
API_KEY="your_api_key"  # Your API key
```

### Step 5: Update Paths

Edit user_modules.ini - change ~/YourPath/ to your actual path.

### Step 6: Add to Bar

Add weather module to your polybar/waybar config.

---

## Requirements

- Linux desktop
- curl
- OpenWeatherMap API key (free)

---

## License & Credits

Modified and enhanced for Linux desktop use.