
IMAGE_NAME="geschke/php-fpm-swrm"

# Define an associative array that maps directory names to image tags
declare -A images=(
  ["ubuntu-22.04"]="v8.1-fpm"
  ["ubuntu-22.04-sury-8.2"]="v8.2-fpm-ubuntu22.04-sury"

)
