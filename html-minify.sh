#!/bin/bash

# Known issues:
# - if html line have two paths only one file considered
# - fails if js file has backticks

command -v html-minifier >/dev/null 2>&1 || { echo "Error: to install missing deps run: npm i -g html-minifier uglify-js cleancss svgo" >&2; exit 1; }
command -v uglifyjs >/dev/null 2>&1 || { echo "Error: to install missing deps run: npm i -g html-minifier uglify-js cleancss svgo" >&2; exit 1; }
command -v cleancss >/dev/null 2>&1 || { echo "Error: to install missing deps run: npm i -g html-minifier uglify-js cleancss svgo" >&2; exit 1; }
command -v svgo >/dev/null 2>&1 || { echo "Error: to install missing deps run: npm i -g html-minifier uglify-js cleancss svgo" >&2; exit 1; }

if [[ $# -eq 0 ]]; then
    html_file=index.html
else
    html_file="$1"
    dir=$PWD
    cd $(dirname $html_file)
    html_file=$(basename $html_file)
fi

if [[ -f "$html_file" ]]; then
    awk '
    {
        if (match($0, /<script src="([^"]+\.js)"><\/script>/)) {
            file = substr($0, RSTART+13, RLENGTH-24)
            print "´"file"´\n"substr($0, RSTART+24+length(file))
        } else if (match($0, /<link rel="stylesheet" href="([^"]+\.css)">/)) {
            file = substr($0, RSTART+29, RLENGTH-31)
            print "´"file"´\n"substr($0, RSTART+31+length(file))
        } else if (match($0, /<link rel="shortcut icon" type="image\/svg\+xml" href="([^"]+\.svg)">/)) {
            file = substr($0, RSTART+53, RLENGTH-55)
            print "´SVG:"file"´\n"substr($0, RSTART+55+length(file))
        } else {
            print $0
        }
    }
    ' "$html_file" > "${html_file}.tmp"
    # Minify and replace content
    while IFS= read -r line; do
        if [[ $line =~ ´([^\"]+)´ ]]; then
            file="${BASH_REMATCH[1]}"
            echo processing "$file"
            if [[ "$file" == SVG:* ]]; then
                file="${file#SVG:}"
                if [[ -f "$file" ]]; then
                    svgo "$file" -o "min.${file}"
                    svg_content=$(cat "min.${file}" | sed 's/</\%3C/g; s/>/\%3E/g; s/#/\%23/g; s/"/'"'"'/g')
                    sed -i "s|´SVG:${file}´|<link rel=\"shortcut icon\" type=\"image/svg+xml\" href=\"data:image/svg+xml,${svg_content}\">|" "${html_file}.tmp"
                else
                    echo "Warning: SVG file $file not found."
                fi
            elif [[ -f "$file" ]]; then
                if [[ "$file" == *.js ]]; then
                    start_tag='<script>'
                    end_tag='<\/script>'
                    uglifyjs $file -c -m > "min.${file}"
                elif [[ "$file" == *.css ]]; then
                    start_tag='<style>'
                    end_tag='<\/style>'
                    cleancss $file > "min.${file}"
                fi
                escaped_content=$(sed 's/[&/\]/\\&/g' < "min.${file}")

                sed -i "s/´${file}´/${start_tag}${escaped_content}${end_tag}/" "${html_file}.tmp"
            else
                echo "Warning: File $file not found."
            fi
        fi
    done < "${html_file}.tmp"

    cp "$html_file" ".original-${html_file}"
    echo generated ".original-${html_file}"
    html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css true --minify-js true "${html_file}.tmp" > "$html_file"
fi

# Clean up generated files
rm min.*.js min.*.css min.*.svg "${html_file}.tmp"
cd $dir
