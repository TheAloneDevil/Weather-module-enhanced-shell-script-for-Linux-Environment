#!/bin/bash
# Polybar Weather Module
# Fetches weather data from OpenWeatherMap API
# Based on reference: https://github.com/kijimoshi1337/Regulus-Spotify/tree/main/scripts

# Configuration - User needs to set these values
CITY_ID="XXXXXXX"  # City, State, Country
API_KEY="dafac2133433c1e66XXXXXXXXXXXXXXX"  # Get from https://home.openweathermap.org/api_keys
UNITS="metric"          # metric/imperial
LANG="en"              # Language code

# Cache file location
CACHE_FILE="$HOME/.cache/weather.json"
CACHE_DURATION=600  # 10 minutes in seconds

# Calculate moon phase (0-29 days)
# Returns: 14-15 = full moon
get_moon_phase() {
    local year=$(date +%Y)
    local month=$(date +%m)
    local day=$(date +%d)
    
    # Convert month and year to algorithm format
    if [ "$month" -lt 3 ]; then
        year=$((year - 1))
        month=$((month + 12))
    fi
    
    local a=$((year / 100))
    local b=$((2 - a + (a / 4)))
    local c=$((36525 * (year + 4716) / 100))
    local d=$((306 * (month + 1) / 10))
    local jd=$((c + d + day + b - 1524))
    
    local days_since_new=$((jd - 2451549))
    
    # Use awk instead of bc for calculation
    local days_into_cycle=$(awk "BEGIN {printf \"%.0f\", $days_since_new / 29.53}")
    
    echo "$days_into_cycle"
}
# Check if today is full moon (day 14-15 of cycle)
is_full_moon() {
    local phase=$(get_moon_phase)
    if [ "$phase" -ge 13 ] && [ "$phase" -le 16 ]; then
        return 0  # True
    fi
    return 1  # False
}
# Weather icons based on OpenWeatherMap condition codes
# Using Font Awesome icons for better compatibility
get_icon() {
    local condition=$1
    local is_night=$(echo "$condition" | grep -q "n$" && echo "1" || echo "0")
    
    # Check if clear night during full moon
    if [ "$condition" = "01n" ] && is_full_moon; then
        echo "%{F#87CEEB}%{T18}󰽤%{T-}%{T9} %{T-}"  # Full moon with overlay pattern
        return
    fi
    
    case $condition in
        # Clear sky
        01d) icon="%{T18} %{T-}" ;;  # Sun (fa-sun-o)
        01n) icon="%{T17}%{T-}%{T9} %{T-}" ;;  # Moon (fa-moon-o)
        
        # Few clouds
        02d) icon="%{T33}%{T-} " ;;  # Cloud sun (fa-cloud)
        02n) icon="%{T33}%{T-} " ;;  # Cloud moon (fa-cloud)
        
        # Scattered clouds
        03d) icon="%{T18}%{T-} " ;;  # Cloud (fa-cloud)
        03n) icon="%{T18}%{T-} " ;;  # Cloud (fa-cloud)
        
        # Broken/overcast clouds
        04d) icon="%{T6} %{T-}" ;;
        04n) icon="%{T6} %{T-}" ;;
        
        # Rain
        10d) icon="%{T18} %{T-}" ;;
        10n) icon="%{T18} %{T-}" ;;
        
        # Shower rain
        09d) icon="%{T18} %{T-}" ;;
        09n) icon="%{T18} %{T-}" ;;
        
        # Drizzle
        3*) icon="%{T6} %{T-}" ;;
        
        # Thunderstorm
        11d) icon="%{T18} %{T-}" ;;  # Lightning (fa-bolt)
        11n) icon="%{T18} %{T-}" ;;  # Lightning (fa-bolt)
        
        # Snow
        13d) icon="%{T18} %{T-}" ;;  # Snow (fa-snowflake-o)
        13n) icon="%{T18} %{T-}" ;;  # Snow (fa-snowflake-o)
        
        # Mist/Fog
        50d) icon="%{T18}󰖑 %{T-}" ;;  # Fog (fa-low-vision)
        50n) icon="%{T18}󰖑 %{T-}" ;;  # Fog (fa-low-vision)
        
        # Fallback patterns
        *d) icon="%{T18} %{T-}" ;;   # Default day = sun
        *n) icon="%{T18} %{T-}" ;;   # Default night = moon
        *) icon="%{T18} %{T-}" ;;    # Default = sun
    esac
    echo "$icon"
}
get_icon_color() {
    local condition=$1
    case $condition in
        01d) echo "#F98006" ;;  # Sun - orange
        01n) echo "#87CEEB" ;;  # Moon - light blue
        02d) echo "#CC9900" ;;  # Few clouds day - Orangish Yellow
        02n) echo "#3C3C5D" ;;  # Few clouds night - Purple
        03*) echo "#CFD8DC" ;;  # Scattered clouds - light gray
        04*) echo "#B0BEC5" ;;  # Broken/overcast - lighter gray
        09*) echo "#29B6F6" ;;  # Shower rain - vibrant light blue
        10*) echo "#03A9F4" ;;  # Rain - vibrant blue
        11*) echo "#FFEB3B" ;;  # Thunderstorm - bright yellow
        13*) echo "#B3E5FC" ;;  # Snow - light blue
        50*) echo "#CFD8DC" ;;  # Mist/Fog - light gray
        3*) echo "#4FC3F7" ;;  # Drizzle - vibrant pale blue
        *) echo "" ;;
    esac
}
# Fetch weather data
fetch_weather() {
    local url="https://api.openweathermap.org/data/2.5/weather?id=${CITY_ID}&appid=${API_KEY}&units=${UNITS}&lang=${LANG}"
    curl -s --connect-timeout 10 --max-time 30 -H "User-Agent: polybar-weather" "$url" -o "$CACHE_FILE"
    if [ $? -ne 0 ] || [ ! -s "$CACHE_FILE" ]; then
        echo '{"error": "Failed to fetch"}' > "$CACHE_FILE"
    fi
}
# Display weather
display_weather() {
    # Check if cache is stale (skip if just refreshed)
    if [ ! -f "$CACHE_FILE" ]; then
        fetch_weather
    elif [ "$JUST_REFRESHED" != "1" ]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
        if [ "$cache_age" -gt "$CACHE_DURATION" ]; then
            fetch_weather
        fi
    fi
    
    # Check for error response
    if grep -q '"error"' "$CACHE_FILE" 2>/dev/null; then
        echo "%{F#ff6b6b}󰌸%{F-} N/A"
        return
    fi
    
    # Parse JSON - try jq first, fallback to grep
    local temp=""
    local icon_code=""
    local description=""
    
    if command -v jq >/dev/null 2>&1; then
        temp=$(jq -r '.main.feels_like' "$CACHE_FILE" 2>/dev/null)
        icon_code=$(jq -r '.weather[0].icon' "$CACHE_FILE" 2>/dev/null)
        description=$(jq -r '.weather[0].description' "$CACHE_FILE" 2>/dev/null)
    else
        # Fallback parsing with grep/sed (for single-line JSON)
        temp=$(grep -o '"feels_like":[0-9.-]*' "$CACHE_FILE" | sed 's/"feels_like"://')
        icon_code=$(grep -o '"icon":"[^"]*"' "$CACHE_FILE" | head -1 | sed 's/"icon":"//;s/"//')
        description=$(grep -o '"description":"[^"]*"' "$CACHE_FILE" | head -1 | sed 's/"description":"//;s/"//')
    fi
    
    # Validate data
    if [ -z "$temp" ] || [ "$temp" = "null" ] || [ -z "$icon_code" ] || [ "$icon_code" = "null" ]; then
        echo "%{F#ff6b6b}󰌸%{F-} N/A"
        return
    fi
    
    # Round temperature
    local temp_int=$(printf "%.0f" "$temp")
    local unit_symbol="°C"
    [ "$UNITS" = "imperial" ] && unit_symbol="°F"
    
    # Get icon and color
    local icon=$(get_icon "$icon_code")
    local icon_color=$(get_icon_color "$icon_code")
    
    # Output - icon with its own font and color, temp/desc plain
    local output="${icon}"
    
    if [ -n "$icon_color" ]; then
        output="%{F${icon_color}}${icon}%{F-}"
    fi
    
    output+=" ${temp_int}${unit_symbol}, ${description}"
    printf "%s\n" "$output"
}
# Main
JUST_REFRESHED=0
if [ "$1" = "refresh" ]; then
    fetch_weather
    JUST_REFRESHED=1
fi
display_weather
