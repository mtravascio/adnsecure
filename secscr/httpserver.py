import http.server
import socketserver
import argparse

parser=argparse.ArgumentParser(description="Avvia un Server HTTP per servire un file .scr")
parser.add_argument("file",help="file.scr da servire")

args=parser.parse_args()

# Imposta il nome del file da condividere
FILE_TO_SERVE = args.file

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == f"/{FILE_TO_SERVE}":
            self.send_response(200)
            self.send_header("Content-type", "application/octet-stream")
            self.send_header("Content-Disposition", f"attachment; filename={FILE_TO_SERVE}")
            self.end_headers()
            with open(FILE_TO_SERVE, 'rb') as file:
                self.wfile.write(file.read())
        else:
            self.send_error(404, "File non trovato.")

# Imposta la porta del server
PORT = 8080

with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    print(f"Server in esecuzione su http://localhost:{PORT}/{FILE_TO_SERVE}")
    httpd.serve_forever()
