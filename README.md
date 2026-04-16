# Enhanced Weather Module for Linux Desktop

![Weather Module](Screenshots/2.png)

<p align="center">
<img src="Screenshots/3.png" width="45%">
</p>

This package provides an enhanced weather module for Linux desktop.

## Files Included

1. **weather.sh** - Main weather script
2. **user_modules.ini** - Module configuration
3. **README.md** - This file

---

## Features

- Fetches weather from OpenWeatherMap API
- Custom weather icons
- Moon phase detection (full moon)
- 30-minute update interval
- Caching
- fetch_weather - timeout & user-agent added
- Fallback JSON parsing - fixed for single-line
- Output - only icon has color
- get_temp_color - removed
- refresh functionality - added
- JUST_REFRESHED logic - added

---

## Installation

### Step 1: Choose Location

mkdir -p ~/YourPath

### Step 2: Copy Files

cp weather.sh ~/YourPath/

cp user_modules.ini ~/YourPath/

### Step 3: Make Script Executable

chmod +x ~/YourPath/weather.sh

### Step 4: Get API Key and City ID

Edit weather.sh (lines 8-9):

**Getting CITY_ID:**
1. Go to https://openweathermap.org/cities
2. Search your city
3. City ID is the number in URL (e.g., London = 2643743)
   - Or ask ChatGPT: "What is the OpenWeatherMap city ID for [Your City]?"

**Getting API_KEY:**
1. Go to https://home.openweathermap.org/api_keys
2. Sign up at https://openweathermap.org (if needed)
3. Go to API Keys section
4. Click "Create New API Key" - give it a name (e.g., "Newbar")
5. Copy the key

Update weather.sh (lines 8-9):
```bash
CITY_ID="1234567"  # Your city ID
API_KEY="your_key"  # Your API key
```

### Step 5: Update Paths

Edit user_modules.ini - change ~/YourPath/ to your path.

### Step 6: Add to Bar

---

## Font Values

This module uses Nerd Fonts with these font numbers (font-n = T(n+1)):
- T6 = font-5 = "Iosevka Nerd Font:size=18;4"
- T9 = font-8 = "Iosevka Nerd Font:size=13;4"
- T17 = font-16 = "Iosevka Nerd Font:size=11;-3"
- T18 = font-17 = "Iosevka Nerd Font:size=13;3"
- T33 = font-32 = "Iosevka Nerd Font:size=14;4"

Make sure your polybar config has these fonts defined.

## Requirements

- Linux desktop
- curl (command-line tool for APIs - usually pre-installed)
- OpenWeatherMap API key (free)

---

## Credits

Modified for Linux desktop use.
