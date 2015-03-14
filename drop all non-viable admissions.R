# Let's exclude the categories that we don't want to count.  Note that some of these exclusions
# are redundant, in the sense that they're already filtered-out by exclusions above them, but the code
# is more readable if they're included:
admissions.trimmed <- admissions.trimmed[which(admissions.trimmed$Operation.Type != "Transfer In" &
                                               admissions.trimmed$Operation.Subtype != "Abandoned" & 
                                               admissions.trimmed$Operation.Subtype != "Abandoned-Field" &
                                               admissions.trimmed$Operation.Subtype != "Abandoned-OTC" & 
                                               admissions.trimmed$Operation.Subtype != "Abandoned-Owner Died" &
                                               admissions.trimmed$Operation.Subtype != "Animal Control" &
                                               admissions.trimmed$Operation.Subtype != "Born in Care" & 
                                               admissions.trimmed$Operation.Subtype != "DOA" & 
                                               admissions.trimmed$Operation.Subtype != "Euthanasia Request" &
                                               admissions.trimmed$Operation.Subtype != "Cat Program-OTC" &
                                               admissions.trimmed$Operation.Subtype != "Feral Cat Program - Field" &
                                               admissions.trimmed$Operation.Subtype != "Field" & 
                                               admissions.trimmed$Operation.Subtype != "Rescue Agency" &
                                               admissions.trimmed$Operation.Subtype != "Rescue Waggin" & 
                                               admissions.trimmed$Operation.Subtype != "Transfer In" &
                                               admissions.trimmed$Operation.Subtype != "Unknown"), ]

# Re-factor the sub-types, so that the excluded factors don't clutter-up the data:
admissions.trimmed$Operation.Subtype <- factor(admissions.trimmed$Operation.Subtype)