-- AddonData/BlizzardCDM.lua
-- Per-spec profile strings for Blizzard Cooldown Manager.
-- Keys are classAndSpecTag integers from CooldownViewerUtil.GetCurrentClassAndSpecTag().

JetUI.BlizzardCDMProfiles = {
    -- Warrior
    [11]  = { profileKey = "JetUI - Arms Warrior",        profileString = "1|NZG9L0NhFMZbbBaDxH2ultuaDY0I8nYgqYGJSO1iaOoj1Wok1ZLe5vpYJBZR2ogSYhYLIS0zQoiJv8HWRSLO895afjkfb877POc4LflKq10oThidhs/0NE2nEU5CJQwTKg9VhbqCIyyYHm8oSZSIMpwaVAnqAOpICiufUIdQ+7gdRuQC6kVquXGoV4SXEE5AvUG9w3mAKhtduK7LT9m4vKnsCWImnHv8rktodzA3BGtsh745547pFxtgdCron5MJmUHW/ISP6CGCREDweCx4GhU8RxhtElvENgcMEfPEguBkCjcGIu1QRaqKcvqAYPWDSrsJi+kOG1WixtoPoyyRY3opqJ+de229kabdhlDXUMz8F9rX1nDl7kC70k5pzXWl3buG/O5mYkGPre/TbOu9WRtaKI8gp9DKA7aYsCdn0qnEbDydiY5ZvdZIanH5Dw==" },
    [12]  = { profileKey = "JetUI - Fury Warrior",        profileString = "1|NdA9S0JxFAZw06CGPkCPpdyWIsis7rUXLStOBQ0NDU1N0SANEYgODuVFvJZhNbREUyK9uToEoRBUWxC0R9QXaOgLdJ4rd/ndP/eee/7nOcVOu9pTDRQu1iAVyAkkCicEOYeMwZmDTMAJB30dtZIy/kxeyCvkFPIHseAkITHINGQSYqJZx1IJktCqgyfILGQRH1mIVs1DziBTbHeI1qU+85uKfaWkhhTzgadBElesMkvelFh30Off7+OHKBkhCSwvoPXD47Dyfk1uSJ3ckjtyz9bfrIug+cvGDfLJxl0cYJSkONcR4bW1Yzx+8dIgCZF+xTaVBtmd4bteAhKuDRTcXzSUv+JN6k6fSnixmKM9PaO2E7Xjx70dWGWj6C7X4n6dZDWwvpVJ723vZHIbq0bEWMmmc/8=" },
    [13]  = { profileKey = "JetUI - Prot Warrior",        profileString = "1|NZC7L4NhGMX7VYuiCCFO9fK11dEk7LZDUlQiJgONNF00ab7FItILom4jY5MOFktN0l1iE1P9AxqzRcLgPZ92+b23533OOU/Fd1wP1v2l21VwFgyDMTAJjoFxcBzsA/tDHqvhAYfBCOgDAQ6i+QkGwCA4gdY3OIm3D3AGnAKn0bwHh8ABMAQmwFFwBEyFPN7ogmmXWzdYShvsLeP3yaztsMHiFzinF1s1GXRC6PzovGY+Rh5UFhMiet40eC0LFeFMqAonwqna3aluR7tndZFow2vwHlAXibSjurPQShqFowvhUrgSroVzoSbcGDy+NKySmyXhrblOuw7TvVS5TC+kXJtIbjhFYcquanKaX3eW8bKr/G+yYdX927tOsZDNO4dbK/a8vVEsOPtZJ184+AM=" },
    -- Paladin
    [21]  = { profileKey = "JetUI - Holy Paladin",        profileString = "PASTE_HOLY_PALADIN_PROFILE_STRING_HERE" },
    [22]  = { profileKey = "JetUI - Prot Paladin",        profileString = "PASTE_PROT_PALADIN_PROFILE_STRING_HERE" },
    [23]  = { profileKey = "JetUI - Ret Paladin",         profileString = "PASTE_RET_PALADIN_PROFILE_STRING_HERE" },
    -- Hunter
    [31]  = { profileKey = "JetUI - BM Hunter",           profileString = "PASTE_BM_HUNTER_PROFILE_STRING_HERE" },
    [32]  = { profileKey = "JetUI - MM Hunter",           profileString = "PASTE_MM_HUNTER_PROFILE_STRING_HERE" },
    [33]  = { profileKey = "JetUI - SV Hunter",           profileString = "PASTE_SV_HUNTER_PROFILE_STRING_HERE" },
    -- Rogue
    [41]  = { profileKey = "JetUI - Assassination Rogue", profileString = "PASTE_ASSASSINATION_ROGUE_PROFILE_STRING_HERE" },
    [42]  = { profileKey = "JetUI - Outlaw Rogue",        profileString = "PASTE_OUTLAW_ROGUE_PROFILE_STRING_HERE" },
    [43]  = { profileKey = "JetUI - Subtlety Rogue",      profileString = "PASTE_SUBTLETY_ROGUE_PROFILE_STRING_HERE" },
    -- Priest
    [51]  = { profileKey = "JetUI - Disc Priest",         profileString = "PASTE_DISC_PRIEST_PROFILE_STRING_HERE" },
    [52]  = { profileKey = "JetUI - Holy Priest",         profileString = "PASTE_HOLY_PRIEST_PROFILE_STRING_HERE" },
    [53]  = { profileKey = "JetUI - Shadow Priest",       profileString = "PASTE_SHADOW_PRIEST_PROFILE_STRING_HERE" },
    -- Death Knight
    [61]  = { profileKey = "JetUI - Blood DK",            profileString = "1|ZdE7SEJRHMdx9Tpl1nboZ8M1Tlu1trnUVEsgRN1RSksILpQVNpUJQRBN0WNzuEJbU1NLOCVhL7dWHfJR9sam/j8zCFo+cO49957vOSftXc/0hDJG6mAclhFwee6LsLzIO1ANmDfQnVBPuGhAPcjLUQvmNXQ3dBe0H2YBZhHaB1WDeYfcHkoDMK+gKlB16BDMW/SrgMsdXxMiFVIlNVInj+SZvJF38km+hNKLUN4SKjuEw8iHdOyfCh2X/PMqdBb6HHqCo2V57jtmaQG5MKfzm/gKScrjaFM4LAtHg4Lf5pRXobpNpqAdzjoTYsNkiZwQyfXMxYT5XjJNrKx7k7uVraq6Z/c3r734T2a0KXntNsltry85kiztfxslypVq3UHrrI2N1hkE07wFuQu5kbzTl/6fnDHCkcSiPRNPJCfHgkPBkQXbnv0G" },
    [62]  = { profileKey = "JetUI - Frost DK",            profileString = "1|PZDLSsNQEIZjiIr2AexfXERc68aCrtwogihYU/oAIghljgTSgJeVRKmCGwVbo2BrcdGn8LIQ9QncuS31BtZKqFbBmQTdfOcw13/+LWOjEh/3As+fBNWhuqC6Qa+gFpZHQU3Y77AboEfQE+gF9Az6Bv2A2qBP1CZAX7gbA32A3kCNhNaRLQtOGYVZ3LT5TaWhDCiNv/M9jGKSMVeXzLDEVqShBNUpkVWG1cvI7wnOGQfXjMMZwbrgnuFLsZ+E0vk9km3WiIw5EVQkd8U4XhI8MEqOIJfQ9ME+ye7LYkvEXMjIftwGsj0msqtcVcswNi8Z2/GzgZ2/ai6MZMaihrA7HFao6rv/AsrRtaGk8OTQj1Q6FBeZwuYow8yLzWJwUyxks6nlBdaC69iLWXctM20OmVOOnXN/AQ==" },
    [63]  = { profileKey = "JetUI - Unholy DK",           profileString = "1|NZFPLwNRFMWn0xYJVRGqt4kYSwsbX8BO1MKi0viThjQWNTV3JqEhXUhQLIgoLZEg0sRHEAu1aWx8Bgu7SopEGishuOeNbn5zc+95950zb8u3XgoPl/ybp+PEPcRhYj2ieVIh4kl6uCPrh1iTRlcKMIlbyfombiLuIA4StxG3yyT9QvYbcQtxgNhL7CPnmhyHuFmG+SfBYYKqefnGbrBoEbBw8AsVC4oeQeFW0DdCHIK0hs4yBAWgCP07pKNYeBbR9IEVVI+CIwKmMD0WnN8LLn4x7cXgWRCoEHcTd0p5UMWuOrZCbZZR2YLkJ6oTWb2zi3OXUuXWBNFVwbQPGBPMJASJIcFsUDAXAtBLijd9+0Pwal/176u73TgqINy4aggbeRuZENZdo4LFavqesii+/80ob67LdF1lcY0GKo0EZtnIqQfCS3k31P8v+SeSmSVn3sxk41Fj0IjbC46V/QM=" },
    -- Shaman
    [71]  = { profileKey = "JetUI - Elemental Shaman",    profileString = "PASTE_ELEMENTAL_SHAMAN_PROFILE_STRING_HERE" },
    [72]  = { profileKey = "JetUI - Enhancement Shaman",  profileString = "PASTE_ENHANCEMENT_SHAMAN_PROFILE_STRING_HERE" },
    [73]  = { profileKey = "JetUI - Resto Shaman",        profileString = "PASTE_RESTO_SHAMAN_PROFILE_STRING_HERE" },
    -- Mage
    [81]  = { profileKey = "JetUI - Arcane Mage",         profileString = "PASTE_ARCANE_MAGE_PROFILE_STRING_HERE" },
    [82]  = { profileKey = "JetUI - Fire Mage",           profileString = "PASTE_FIRE_MAGE_PROFILE_STRING_HERE" },
    [83]  = { profileKey = "JetUI - Frost Mage",          profileString = "PASTE_FROST_MAGE_PROFILE_STRING_HERE" },
    -- Warlock
    [91]  = { profileKey = "JetUI - Affliction Warlock",  profileString = "PASTE_AFFLICTION_WARLOCK_PROFILE_STRING_HERE" },
    [92]  = { profileKey = "JetUI - Demonology Warlock",  profileString = "PASTE_DEMONOLOGY_WARLOCK_PROFILE_STRING_HERE" },
    [93]  = { profileKey = "JetUI - Destruction Warlock", profileString = "PASTE_DESTRUCTION_WARLOCK_PROFILE_STRING_HERE" },
    -- Monk
    [101] = { profileKey = "JetUI - Brewmaster Monk",     profileString = "PASTE_BREWMASTER_MONK_PROFILE_STRING_HERE" },
    [102] = { profileKey = "JetUI - Mistweaver Monk",     profileString = "PASTE_MISTWEAVER_MONK_PROFILE_STRING_HERE" },
    [103] = { profileKey = "JetUI - Windwalker Monk",     profileString = "PASTE_WINDWALKER_MONK_PROFILE_STRING_HERE" },
    -- Druid
    [111] = { profileKey = "JetUI - Balance Druid",       profileString = "PASTE_BALANCE_DRUID_PROFILE_STRING_HERE" },
    [112] = { profileKey = "JetUI - Feral Druid",         profileString = "PASTE_FERAL_DRUID_PROFILE_STRING_HERE" },
    [113] = { profileKey = "JetUI - Guardian Druid",      profileString = "PASTE_GUARDIAN_DRUID_PROFILE_STRING_HERE" },
    [114] = { profileKey = "JetUI - Resto Druid",         profileString = "PASTE_RESTO_DRUID_PROFILE_STRING_HERE" },
    -- Demon Hunter
    [121] = { profileKey = "JetUI - Havoc DH",            profileString = "1|VdC/S8NQEAfwNO1fUBD8djGOonX3P7CLgyBdfVSQFqEiQYguJjqIdJY45K4ZRKcgLraDHepsu+of4Ca4aNAq1btUB5fPe8fx7sc7KhzE054fhEugW1APSRFJFXQProMbIAZfgLcQfYFPQBZ4H9E3KA+yEY1Bi6BCycqNVpQYNAB30X6QyOwJHwvC5rpihHSoCU9xEU+h/SjXcb5k2W/XwuhKwvcNTR+CO3I+N4SXOeG1qtxpkYrS0uqXyqe87PSF02PlRgjnFQ3DJ+FsW+iWhXTmPOfLKnbrd8KsZ9Z9Mqvx/s01Gdu4f1ukw1k/q+UE2Y8NrEA/LCn6q8bdadbqrrdWccrOstlt1n4A" },
    [122] = { profileKey = "JetUI - Vengeance DH",        profileString = "1|VZC7SgNREIb3JqvYqJV/qrWxmoOFffrEJqfIxgsa1mU1WxhRAsFU7hq0MBHtbBSWeHsCH8BWy+hjiJUgKDpjCGLzzcyZ+c/857Sd/Wy6ldnpeR76EFSB7kHH0FegVVAIqkLXcob52QPdgNZAbdABiGeXQOugMmgRtALyc4bV7YNSmS6BlqGKfGTPMqwNhlGQ8oFRzIPuOJofoADNJygXahRqDM0jVn+3uOe8gW65CKoi2JGswtlIInhluPdQfY6nL4yzCcGkYEp8zDNOxiV7Zhy/Mx4voBc4li4ZnS/pxddmwi6tznCPu/Xr7t/GbvwnGth25obeZ1L2wNd66eDxumYk/ImZ7QeN3e0wbuyVC57y/Ki+GQX1MPoB" },
    [123] = { profileKey = "JetUI - Devourer DH",         profileString = "PASTE_ALDRACHI_DH_PROFILE_STRING_HERE" },
    -- Evoker
    [131] = { profileKey = "JetUI - Devastation Evoker",  profileString = "PASTE_DEVASTATION_EVOKER_PROFILE_STRING_HERE" },
    [132] = { profileKey = "JetUI - Preservation Evoker", profileString = "PASTE_PRESERVATION_EVOKER_PROFILE_STRING_HERE" },
    [133] = { profileKey = "JetUI - Augmentation Evoker", profileString = "PASTE_AUGMENTATION_EVOKER_PROFILE_STRING_HERE" },
}
