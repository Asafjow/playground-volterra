resource "volterra_endpoint" "asaf-enp1" {
  name      = "asaf-enp1"
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
resource "volterra_endpoint" "asaf-enp2" {
  name      = "asaf-enp2"
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
resource "volterra_cluster" "tf-cluster" {
  name      = "tf-cluster"
  namespace = "a-sahar"
  loadbalancer_algorithm ="LB_OVERRIDE"
  endpoint_selection  = "LOCAL_PREFERRED"  
  
    endpoints { 
       name = "asaf-enp1" 
           }
           endpoints { 
       name = "asaf-enp2" 
           }
    
}
resource "volterra_route" "myroute" {
  name      = "myroute"
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
                  name ="tf-cluster"
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
                  name ="tf-cluster"
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


//End of the file
//==========================================================================