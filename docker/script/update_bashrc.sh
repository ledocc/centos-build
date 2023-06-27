


cat << EOF >> /home/builder/.bashrc
export PATH=/home/builder/.local/bin:\${PATH:+:\${PATH}}
. /opt/rh/devtoolset-10/enable
export PATH=/usr/lib64/ccache:\${PATH:+:\${PATH}}
alias conan__set_color_dark="export CONAN_COLOR_DARK=1"

EOF


