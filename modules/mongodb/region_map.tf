locals {
  # Atlas regions by Azure locations
  atlas_regions = {
    # NA
    centralus      = "US_CENTRAL"
    eastus         = "US_EAST"
    eastus2        = "US_EAST_2"
    westus         = "US_WEST"
    westus2        = "US_WEST_2"
    westus3        = "US_WEST_3"
    westcentralus  = "US_WEST_CENTRAL"
    southcentralus = "US_SOUTH_CENTRAL"
    brazilsouth    = "BRAZIL_SOUTH"
    canadaeast     = "CANADA_EAST"
    canadacentral  = "CANADA_CENTRAL"

    # EU
    northeurope        = "EUROPE_NORTH"
    westeurope         = "EUROPE_WEST"
    uksouth            = "UK_SOUTH"
    ukwest             = "UK_WEST"
    francecentral      = "FRANCE_CENTRAL"
    italynorth         = "ITALY_NORTH"
    germanywestcentral = "GERMANY_WEST_CENTRAL"
    polandcentral      = "POLAND_CENTRAL"
    switzerlandnorth   = "SWITZERLAND_NORTH"
    norwayeast         = "NORWAY_EAST"

    # APAC
    centralindia       = "INDIA_CENTRAL"
    westindia          = "INDIA_WEST"
    japaneast          = "JAPAN_EAST"
    japanwest          = "JAPAN_WEST"
    koreacentral       = "KOREA_CENTRAL"
    koreasouth         = "KOREA_SOUTH"
    eastasia           = "ASIA_EAST"
    southeastasia      = "ASIA_SOUTH_EAST"
    australiacentral   = "AUSTRALIA_CENTRAL"
    australiaeast      = "AUSTRALIA_EAST"
    australiasoutheast = "AUSTRALIA_SOUTH_EAST"

    # ME
    uaenorth      = "UAE_NORTH"
    qatarcentral  = "QATAR_CENTRAL"
    israelcentral = "ISRAEL_CENTRAL"
  }

  atlas_copy_regions = {
    US_CENTRAL       = "US_EAST"
    US_EAST          = "US_EAST_2"
    US_EAST_2        = "US_EAST"
    US_WEST          = "US_WEST_2"
    US_WEST_2        = "US_WEST_3"
    US_WEST_3        = "US_WEST_2"
    US_WEST_CENTRAL  = "US_CENTRAL"
    US_SOUTH_CENTRAL = "US_CENTRAL"
    BRAZIL_SOUTH     = "BRAZIL_SOUTHEAST"
    CANADA_EAST      = "CANADA_CENTRAL"
    CANADA_CENTRAL   = "CANADA_EAST"

    # EU
    EUROPE_NORTH         = "EUROPE_WEST"
    EUROPE_WEST          = "EUROPE_NORTH"
    UK_SOUTH             = "UK_WEST"
    UK_WEST              = "UK_SOUTH"
    FRANCE_CENTRAL       = "FRANCE_SOUTH"
    ITALY_NORTH          = "FRANCE_CENTRAL"
    GERMANY_WEST_CENTRAL = "GERMANY_NORTH"
    SWITZERLAND_NORTH    = "SWITZERLAND_WEST"
    POLAND_CENTRAL       = "NORWAY_EAST"
    NORWAY_EAST          = "NORWAY_WEST"

    # APAC
    INDIA_CENTRAL        = "INDIA_WEST"
    INDIA_WEST           = "INDIA_CENTRAL"
    JAPAN_EAST           = "JAPAN_WEST"
    JAPAN_WEST           = "JAPAN_EAST"
    KOREA_CENTRAL        = "KOREA_SOUTH"
    KOREA_SOUTH          = "KOREA_CENTRAL"
    ASIA_EAST            = "ASIA_SOUTH_EAST"
    ASIA_SOUTH_EAST      = "ASIA_EAST"
    AUSTRALIA_CENTRAL    = "AUSTRALIA_CENTRAL_2"
    AUSTRALIA_EAST       = "AUSTRALIA_SOUTH_EAST"
    AUSTRALIA_SOUTH_EAST = "AUSTRALIA_EAST"

    # ME
    UAE_NORTH      = "UAE_CENTRAL"
    QATAR_CENTRAL  = "QATAR_CENTRAL"
    ISRAEL_CENTRAL = "ISRAEL_CENTRAL"
  }
}
