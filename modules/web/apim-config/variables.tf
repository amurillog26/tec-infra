variable "main_rg_name" {
  type          = string
}

variable "main_vn_location" {
  type          = string
}

variable "resource_tags" {
  type        = map(string)
  description = "General Tags"
}

variable "apim_name" {
  type        = string
  description = "The name of apim"
}

variable "apim_tec_products" {
  type = list(object({
    pr_name = string
    pr_dis = string
    pr_subs_req = bool
    pr_pub = bool
    users = list(string)
    apis = list(object({
      name = string
      vers = string
      path = string
      service_url = string
      swagger_file = string
    }))
  }))
}
