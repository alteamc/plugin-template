#!/bin/sh
prompt() {
  printf "%s" "$2"
  if [ "$#" -gt 2 ]; then
    printf " [%s]" "$3"
  fi
  printf "%s " ":"
  read -r "$1"
  if [ -z "$(eval printf "%s" '$'"$1")" ]; then
    eval "$1"=\""$(printf "%s" "$3" | sed 's/\\/\\\\/' | sed 's/"/\\"/')"\"
  fi
}

prompt package     "Enter your plugin package"     "com.example"
prompt name        "Enter your plugin name"        "$(basename "$(readlink -f "$(dirname -- "$0")")")"
prompt version     "Enter your plugin version"     "1.0.0"
prompt description "Enter your plugin description" "A clear and concise description of a Spigot plugin."
prompt author      "Enter your plugin author name" "$(whoami)"

# shellcheck disable=SC2154
package_path="$(printf "%s" "$package" | sed 's/\./\//')"
# shellcheck disable=SC2154
package_name="$(printf "%s" "$name" | tr '[:upper:]' '[:lower:]')"

# Configure build.gradle.kts
sed -i 's/group = "com\.example"/group = "'"$package"'"/' "build.gradle.kts"
# shellcheck disable=SC2154
sed -i 's/description = "A clear and concise description of a Spigot plugin\."/description = "'"$description"'"/' "build.gradle.kts"
sed -i 's/prefix = "com.example.myawesomeplugin.dependency"/prefix = "'"$package"'.'"$package_name"'.dependency"/' "build.gradle.kts"

# Rename package and main class
mkdir -p "src/main/java/$package_path"
mv "src/main/java/com/example/myawesomeplugin" "src/main/java/$package_path/$package_name"
mv "src/main/java/$package_path/$package_name/MyAwesomePlugin.java" "src/main/java/$package_path/$package_name/$name.java"
rm -rf "src/main/java/com"

# Configure main class file
sed -i 's/public final class MyAwesomePlugin extends JavaPlugin {/public final class '"$name"' extends JavaPlugin {/' "src/main/java/$package_path/$package_name/$name.java"
sed -i 's/package com.example.myawesomeplugin;/package '"$package"'.'"$package_name"';/' "src/main/java/$package_path/$package_name/$name.java"
sed -i 's/    private static @NotNull MyAwesomePlugin I;/    private static @NotNull '"$name"' I;/' "src/main/java/$package_path/$package_name/$name.java"

# Configure plugin.yml
sed -i 's/name:    "MyAwesomePlugin"/name:    "'"$name"'"/' "src/main/resources/plugin.yml"
sed -i 's/main:    "com.example.myawesomeplugin.MyAwesomePlugin"/main:    "'"$package"'.'"$name"'"/' "src/main/resources/plugin.yml"
# shellcheck disable=SC2154
sed -i 's/version: "1.0"/version: "'"$version"'"/' "src/main/resources/plugin.yml"
sed -i 's/description: "A clear and concise description of a Spigot plugin\."/description: "'"$description"'"/' "src/main/resources/plugin.yml"
# shellcheck disable=SC2154
sed -i 's/author:      "Someone Great"/author:      "'"$author"'"/' "src/main/resources/plugin.yml"

# Configure settings.gradle.kts
sed -i 's/rootProject.name = "MyAwesomePlugin"/rootProject.name = "'"$name"'"/' "settings.gradle.kts"

# Remove configuration script
rm -f -- "$0" "README.md" "LICENSE"

# Create git repository and create initial commit
rm -rf ".git"
git init >"/dev/null"
git add "." >"/dev/null"
git commit -m "Initial commit" >"/dev/null"

echo "Template project configured and is ready for use!"