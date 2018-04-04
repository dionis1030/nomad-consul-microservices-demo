job "sockshop-qm-exec" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    stagger = "10s"
    max_parallel = 1
  }

  # - frontend #
  group "frontend" {
    count = 3

    constraint {
      distinct_hosts = true
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - frontend app - #
    task "front-end" {
      driver = "docker"

      config {
        image = "weaveworksdemos/front-end:master-ac9ca707"
        command = "/usr/local/bin/node"
        args = ["server.js", "--domain=service.consul"]
        hostname = "front-end.service.consul"
        network_mode = "sockshop"
        port_map = {
          http = 8079
        }
      }

      service {
        name = "front-end"
        tags = ["app", "frontend", "front-end"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 128 # 128MB
        network {
          mbits = 10
          port "http" {
            static = 80
          }
        }
      }
    } # - end frontend app - #
  } # - end frontend - #

  # - user - #
  group "user" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "user" {
      driver = "docker"

      env {
	      HATEAOS = "user.service.consul"
      }

      config {
        image = "weaveworksdemos/user:master-5e88df65"
        hostname = "user.service.consul"
        network_mode = "sockshop"
        port_map = {
          http = 80
        }
      }

      vault {
        policies = ["sockshop-read"]
      }

      template {
        data = <<EOH
        MONGO_PASS="{{with secret "secret/sockshop/database/passwords" }}{{.Data.userdb}}{{end}}"
        EOH
        destination = "secrets/user_db.env"
        env = true
      }

      service {
        name = "user"
        tags = ["app", "user"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "http" {}
        }
      }
    } # - end app - #

    # - db - #
    task "user-db" {
      driver = "docker"

      config {
        image = "weaveworksdemos/user-db:master-5e88df65"
        hostname = "user-db.service.consul"
        network_mode = "sockshop"
        port_map = {
          http = 27017
        }
      }

      vault {
        policies = ["sockshop-read"]
      }

      template {
        data = <<EOH
        MONGO_PASS="{{with secret "secret/sockshop/database/passwords" }}{{.Data.userdb}}{{end}}"
        EOH
        destination = "secrets/user_db.env"
        env = true
      }

      service {
        name = "user-db"
        tags = ["db", "user", "user-db"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 96 # 96MB
        network {
          mbits = 10
	        port "http" {}
        }
      }
    } # - end db - #
  } # - end user - #

  # - catalogue - #
  group "catalogue" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "catalogue" {
      driver = "docker"

      config {
        image = "weaveworksdemos/catalogue:0.3.5"
        hostname = "catalogue.service.consul"
        network_mode = "sockshop"
        port_map = {
          http = 80
        }
      }

      service {
        name = "catalogue"
        tags = ["app", "catalogue"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 128 # 32MB
        network {
          mbits = 10
          port "http" {}
        }
      }
    } # - end app - #

    # - db - #
    task "cataloguedb" {
      driver = "docker"

      config {
        image = "weaveworksdemos/catalogue-db:0.3.5"
        hostname = "catalogue-db.service.consul"
        network_mode = "sockshop"
        port_map = {
          http = 3306
        }
      }

      vault {
	      policies = ["default", "ssh_policy"]
      }

      template {
        data = <<EOH
	      MYSQL_ROOT_PASSWORD="{{with secret "ssh-nomad/creds/otp_nomad" "ip=172.17.0.1"}}{{.Data.key}}{{end}}"
        EOH
	      destination = "secrets/mysql_root_pwd.env"
        env = true
      }

      env {
        MYSQL_DATABASE = "socksdb"
        MYSQL_ALLOW_EMPTY_PASSWORD = "false"
      }

      service {
        name = "catalogue-db"
        tags = ["db", "catalogue", "catalogue-db"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 256 # 256MB
        network {
          mbits = 10
	        port "http" {}
        }
      }

    } # - end db - #
  } # - end catalogue - #

  # - carts - #
  group "carts" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "carts" {
      driver = "docker"

      env {
	      db = "carts-db.service.consul"
      }

      config {
        image = "weaveworksdemos/carts:0.4.8"
        hostname = "carts.service.consul"
        network_mode = "sockshop"
        port_map = {
          http = 80
        }
      }

      service {
        name = "carts"
        tags = ["app", "carts"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 1024 # 1024MB
        network {
          mbits = 10
          port "http" {}
        }
      }
    } # - end app - #

    # - db - #
    task "cartdb" {
      driver = "docker"

      config {
        image = "mongo:3.4.3"
        hostname = "carts-db.service.consul"
        network_mode = "sockshop"
        port_map = {
          http = 27017
        }
      }

      service {
        name = "carts-db"
        tags = ["db", "carts", "carts-db"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 128 # 128MB
        network {
          mbits = 10
	        port "http" {}
        }
      }
    } # - end db - #
  } # - end carts - #

  # - orders - #
  group "orders" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "orders" {
      driver = "docker"

      env {
        db = "orders-db.service.consul"
	      domain = "service.consul"
      }

      config {
        image = "weaveworksdemos/orders:0.4.7"
        hostname = "orders.service.consul"
        network_mode = "sockshop"
        port_map = {
          http = 80
        }
      }

      service {
        name = "orders"
        tags = ["app", "orders"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 1024 # 1024MB
        network {
          mbits = 10
          port "http" {}
        }
      }
    } # - end app - #

    # - db - #
    task "ordersdb" {
      driver = "docker"

      config {
        image = "mongo:3.4.3"
        hostname = "orders-db.service.consul"
        network_mode = "sockshop"
	      port_map = {
	         http = 27017
	      }
      }

      service {
        name = "orders-db"
        tags = ["db", "orders", "orders-db"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 64 # 64MB
        network {
          mbits = 10
	        port "http" {}
        }
      }
    } # - end db - #
  } # - end orders - #

  # - payment - #
  group "payment" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "payment" {
      driver = "docker"

      config {
        image = "weaveworksdemos/payment:0.4.3"
        hostname = "payment"
        network_mode = "sockshop"
        port_map = {
          http = 80
        }
      }

      service {
        name = "payment"
        tags = ["app", "payment"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 16 # 16MB
        network {
          mbits = 10
          port "http" {}
        }
      }
    } # - end app - #
  } # - end payment - #


  # - backoffice - #
  group "backoffice" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - rabbitmq - #
    task "rabbitmq" {
      driver = "docker"

      config {
        image = "rabbitmq:3.6.8"
        hostname = "rabbitmq.service.consul"
        network_mode = "sockshop"
      }

      service {
        name = "rabbitmq"
        tags = ["message-broker", "rabbitmq"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 160 # 160MB
        network {
          mbits = 10
	        port "http" {
            static = 5672
          }
        }
      }
    } # - end rabbitmq - #

    # - shipping - #
    task "shipping" {
      driver = "docker"

      env {
	      spring_rabbitmq_host = "${NOMAD_IP_http}"
      }

      config {
        image = "weaveworksdemos/shipping:0.4.8"
        hostname = "shipping.service.consul"
        network_mode = "sockshop"
        port_map = {
          http = 80
        }
      }

      service {
        name = "shipping"
        tags = ["app", "shipping"]
        port = "http"
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 1024 # 1024MB
        network {
          mbits = 10
          port "http" {}
        }
      }
    } # - end shipping - #

    # - app - #
    task "queue-master" {
      driver = "raw_exec"

      config {
        command = "/usr/bin/java"
        args = ["-jar", "/home/ubuntu/jars/queue-master.jar", "--port=8099", "--spring.rabbitmq.host=${attr.unique.network.ip-address}"]
      }

      service {
        name = "queue-master"
        tags = ["app", "queue-master"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 1024 # 1024MB
        network {
          mbits = 10
          port "http" {
            static = "8099"
          }
        }
      }
    } # - end queue-master - #

  } # - end backoffice - #
}
