resource "google_datastream_connection_profile" "cdc_sales" {
    display_name          = "Connection profile"
    location              = var.project_region
    connection_profile_id = var.datastream_conn_db

    postgresql_profile {
        hostname = var.public_ip_address
        username = var.user
        password = var.password
        database = var.database_name
    }

}

resource "google_datastream_connection_profile" "bucket" {
    display_name          = "Connection profile bucket"
    location              = var.project_region
    connection_profile_id = var.datastream_conn_bucket

    gcs_profile {
        bucket    = var.datastream_conn_bucket
        root_path = "/sales_data"
    }
}

resource "google_datastream_stream" "cdc_sales"  {
    display_name = "Postgres to Cloud Storage"
    location     = var.project_region
    stream_id    = var.datastream_name
    desired_state = "RUNNING"

    source_config {
        source_connection_profile = google_datastream_connection_profile.cdc_sales.id
        postgresql_source_config {
            max_concurrent_backfill_tasks = 12
            publication      = var.publication_name
            replication_slot = var.replication_name
            include_objects {
                postgresql_schemas {
                    schema = "public"
                    postgresql_tables {
                        table = "vendas"
                    }
                }
            }
        }
        
    }
    backfill_all {  
    }

    destination_config {
        destination_connection_profile = google_datastream_connection_profile.bucket.id
        gcs_destination_config  {
            file_rotation_mb = 200
            file_rotation_interval = "60s"
            json_file_format {
                schema_file_format = "NO_SCHEMA_FILE"
            }
            }
        }
    }