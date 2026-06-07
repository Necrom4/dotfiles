# Referencing:
# https://opensource.apple.com/source/IOHIDFamily/IOHIDFamily-1035.41.2/IOHIDFamily/IOHIDUsageTables.h.auto.html
SECTION="0x700000064"
# ESCAPE="0x700000029"
BACKQUOTE="0x700000035"
# CAPS_LOCK="0x700000039"
# L_SHIFT="0x7000000E1"
# R_COMMAND="0x7000000E7"
# L_CONTROL="0x7000000E0"

MAPPINGS=""
function Map { # FROM TO
  ENTRY="{\"HIDKeyboardModifierMappingSrc\":${1},\"HIDKeyboardModifierMappingDst\":${2}}"
  MAPPINGS="${MAPPINGS:+${MAPPINGS},}${ENTRY}"
}

# Map "${CAPS_LOCK}" "${ESCAPE}"
Map "${SECTION}" "${BACKQUOTE}"
Map "${BACKQUOTE}" "${SECTION}"

hidutil property --set "{\"UserKeyMapping\":[${MAPPINGS}]}"
