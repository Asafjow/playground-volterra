//==========================================================================
//Definition of the Origin, 1-origin.tf
//Start of the TF file
resource "volterra_origin_pool" "op-ip-internal" {
  name                   = "demo-ip-internal"
  //Name of the namespace where the origin pool must be deployed
  namespace              = "a-sahar"
 
   origin_servers {

    public_name {
      dns_name = "sentence2.emea.f5se.com"
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
  name      = "waap-asaf2"
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
  domains = ["asaftf2.emea-ent.f5demos.com"]
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
        name = "myroute2"
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
resource "volterra_endpoint" "asaf-endpoint1" {
  name      = "asaf-endpoint1"
  namespace = "a-sahar"

    dns_name  = "www.test.com"
    port = "443"
    protocol = "TCP"
    where {
      site {
        network_type = "VIRTUAL_NETWORK_SITE_LOCAL"
      }
    }
            

}
resource "volterra_endpoint" "asaf-endpoint2" {
  name      = "asaf-endpoint2"
  namespace = "a-sahar"

    dns_name  = "www.test2.com"
    port = "443"
    protocol = "TCP"
    where {
      site {
        network_type = "VIRTUAL_NETWORK_SITE_LOCAL"
      }
    }
            

}
resource "volterra_cluster" "tf-cluster2" {
  name      = "tf-cluster2"
  namespace = "a-sahar"
  loadbalancer_algorithm ="LB_OVERRIDE"
  endpoint_selection  = "LOCAL_PREFERRED"  
  
    endpoints { 
       name = "asaf-endpoint1" 
           }
           endpoints { 
       name = "asaf-endpoint2" 
           }
    
}
resource "volterra_route" "myroute2" {
  name      = "myroute2"
  namespace = "a-sahar"
  routes {
    disable_custom_script = true
    disable_location_add  = true
      
    match  {
        http_method = "any"   
        path {
        // One of the arguments from this list "prefix path regex" must be set
        prefix = "/test-only/"
             }
            }   
        route_destination {
          priority = "default"
          auto_host_rewrite = "0"
          host_rewrite = "disable"
              destinations {
                cluster {
                  name ="tf-cluster2"
                        }
              }

        }  
        waf_type {
              app_firewall {
                app_firewall {
                name = "default-waf"
                             }    
                          }
              } 
      
   
    }
  routes {
    disable_custom_script = true
    disable_location_add  = true
      
    match  {
        http_method = "any"   
        path {
        // One of the arguments from this list "prefix path regex" must be set
        prefix = "/admin-only/"
             }
            }   
        route_destination {
          priority = "default"
          auto_host_rewrite = "0"
          host_rewrite = "disable"
              destinations {
                cluster {
                  name ="tf-cluster2"
                        }
              }

        }  
        waf_type {
              app_firewall {
                app_firewall {
                name = "api-waf"
                             }    
                          }
              } 
      
   
    }
    
}
# data "volterra_http_loadbalancer_state" "state" {
#   name = "lb-https-tf"
#   namespace = "a-sahar"
# }

//End of the file
//==========================================================================
//End of the file
//==========================================================================