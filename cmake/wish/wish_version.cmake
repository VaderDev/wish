#

include_guard(GLOBAL)

set(wish_version v5.5.3)

# Remove the leading 'v' from version. The v is present for convenience with search-and-replace on new release.
string(SUBSTRING "${wish_version}" 1 -1 wish_version)
