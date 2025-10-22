variable "user_names" {
    description = "Create IAM users with those names"
    type = list(string)
    default = [ "red", "blue", "green" ]
}