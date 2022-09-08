//==========================================================================
//Definition of the Origin, 1-origin.tf
//Start of the TF file
resource "volterra_origin_pool" "op-ip-internal" {
  name                   = "demo-ip-internal"
  //Name of the namespace where the origin pool must be deployed
  namespace              = "a-sahar"
 
   origin_servers {

    public_name {
      dns_name = "sentence.emea.f5se.com"
    }

    labels = {
    }
  }

  no_tls = true
  port = "80"
  endpoint_selection     = "LOCALPREFERED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}
//End of the file
//==========================================================================

//Definition of the WAAP Policy
resource "volterra_app_firewall" "waap-tf" {
  name      = "waap-asaf"
  namespace = "a-sahar"

  // One of the arguments from this list "allow_all_response_codes allowed_response_codes" must be set
  allow_all_response_codes = true
  // One of the arguments from this list "default_anonymization custom_anonymization disable_anonymization" must be set
  default_anonymization = true
  // One of the arguments from this list "use_default_blocking_page blocking_page" must be set
  use_default_blocking_page = true
  // One of the arguments from this list "default_bot_setting bot_protection_setting" must be set
  default_bot_setting = true
  // One of the arguments from this list "default_detection_settings detection_settings" must be set
  default_detection_settings = true
  // One of the arguments from this list "use_loadbalancer_setting blocking monitoring" must be set
  use_loadbalancer_setting = true
  // Blocking mode - optional - if not set, policy is in MONITORING
  blocking = true
}

//==========================================================================
//Definition of the Load-Balancer, 2-https-lb.tf
//Start of the TF file
resource "volterra_http_loadbalancer" "lb-https-tf" {
  depends_on = [volterra_origin_pool.op-ip-internal]
  //Mandatory "Metadata"
  name      = "lb-https-tf"
  //Name of the namespace where the origin pool must be deployed
  namespace = "a-sahar"
  //End of mandatory "Metadata" 
  //Mandatory "Basic configuration" with Auto-Cert 
  domains = ["asaftf.emea-ent.f5demos.com"]
  https_auto_cert {
    add_hsts = true
    http_redirect = true
    no_mtls = true
    enable_path_normalize = true
    tls_config {
        default_security = true
      }
  }
  default_route_pools {
      pool {
        name = "demo-ip-internal"
        namespace = "a-sahar"
      }
      weight = 1
    }
  routes {
    custom_route_object {
      route_ref {
        name = "myroute"
                }
                        }
         }
  //Mandatory "VIP configuration"
  advertise_on_public_default_vip = true
  //End of mandatory "VIP configuration"
  //Mandatory "Security configuration"
  no_service_policies = true
  no_challenge = true
  disable_rate_limit = true
  //WAAP Policy reference, created earlier in this plan - refer to the same name
  app_firewall {
    name = "waap-asaf"
    namespace = "a-sahar"
  }
  multi_lb_app = true
  user_id_client_ip = true
  //End of mandatory "Security configuration"
  //Mandatory "Load Balancing Control"
  source_ip_stickiness = true
  //End of mandatory "Load Balancing Control"
  
}
//End of the file
//==========================================================================