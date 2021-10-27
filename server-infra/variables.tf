# Set this to the region closest to you - do not change this value 
# after it's already set because it will recreate everything
# Region list: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html
variable "region" {
    description = "Default region for server"
    type        = string
    default     = "us-west-1"
}

variable "project_name" {
    description = "Name of project tied to resources on AWS"
    type        = string
    default     = "minecraft-server"
}


# You will either have to create a new keypair to use that matches the default value
# or switch out default value
variable "key_pair_name" {
    description = "Name of key-pair to use from AWS"
    type        =  string
    default     = "mc-keypair"
}

# You need to update the default here
variable "rcon_password" {
    description = "Strong password used for RCON"
    type        = string
    default     = "pAs$w0rD"
}