# locale  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter09/locale.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
locale -a

# TEMPLATE (edit before running): LC_ALL=<locale name> locale charmap

# TEMPLATE (edit before running): LC_ALL=<locale name> locale language
# TEMPLATE (edit before running): LC_ALL=<locale name> locale charmap
# TEMPLATE (edit before running): LC_ALL=<locale name> locale int_curr_symbol
# TEMPLATE (edit before running): LC_ALL=<locale name> locale int_prefix

cat > /etc/profile << "EOF"
# Begin /etc/profile

for i in $(locale); do
  unset ${i%=*}
done

if [[ "$TERM" = linux ]]; then
  export LANG=C.UTF-8
else
# TEMPLATE (edit before running):   export LANG=<ll>_<CC>.<charmap><@modifiers>
fi

# End /etc/profile
EOF
