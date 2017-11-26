job "hdfs" {

  datacenters = [ "dc-1" ]

  group "NameNode" {

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    task "NameNode" {

      driver = "docker"

      config {
        image = "rcgenova/hadoop-2.7.3"
        command = "bash"
        args = [ "-c", "hdfs namenode -format && exec hdfs namenode -D fs.defaultFS=hdfs://${NOMAD_ADDR_ipc}/ -D dfs.permissions.enabled=false" ]
        network_mode = "host"
        port_map {
          ipc = 8020
          ui = 50070
        }
        dns_servers = ["127.0.0.1"]
      }

      resources {
        memory = 256
        network {
          port "ipc" {
            static = "8020"
          }
          port "ui" {
            static = "50070"
          }
        }
      }

      service {
        name = "hdfs"
        port = "ipc"
      }
    }
  }

  group "DataNode" {

    count = 2

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }
    
    task "DataNode" {

      driver = "docker"

      config {
        network_mode = "host"
        image = "rcgenova/hadoop-2.7.3"
        args = [ "hdfs", "datanode"
          , "-D", "fs.defaultFS=hdfs://hdfs.service.consul/"
          , "-D", "dfs.permissions.enabled=false"
        ]
        // args = [ "hdfs", "datanode"
        //   , "-D", "fs.defaultFS=hdfs://192.168.0.154:8020/"
        //   , "-D", "dfs.permissions.enabled=false"
        // ]
        port_map {
          data = 50010
          ipc = 50020
          ui = 50075
        }
        dns_servers = ["127.0.0.1"]
      }

      resources {
        memory = 256
        network {
          port "data" {
            static = "50010"
          }
          port "ipc" {
            static = "50020"
          }
          port "ui" {
            static = "50075"
          }
        }
      }

    }
  }

}
