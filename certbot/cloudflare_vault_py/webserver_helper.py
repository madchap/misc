import threading

try: 
  from http.server import HTTPServer, SimpleHTTPRequestHandler
except ImportError:
    from http.server import BaseHTTPServer
    HTTPServer = BaseHTTPServer.HTTPServer

def up():
  thread.start()
  print('starting server on port {}'.format(server.server_port))

def down():
  server.shutdown()
  print('stopping server on port {}'.format(server.server_port))

port = 8080
web_root = "/var/www/html"
server = HTTPServer(('localhost', port), SimpleHTTPRequestHandler(directory=web_root))
thread = threading.Thread(target = server.serve_forever)
thread.deamon = True