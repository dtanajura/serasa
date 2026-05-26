import socket

def lambda_handler(event, context):
    server = "10.99.48.51"
    port = 443
    # server = "10.96.170.203"
    # port = 8081
    timeout = 10

    try:
        # Cria um socket TCP/IP
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        
        # Tenta conectar ao servidor
        sock.connect((server, port))
        return {
            'statusCode': 200,
            'body': f"Conexão bem-sucedida com {server}:{port}"
        }
    except socket.error as e:
        return {
            'statusCode': 500,
            'body': f"Erro ao conectar com {server}:{port} - {e}"
        }
    finally:
        sock.close()