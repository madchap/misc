import threading
import functools

try: 
  from http.server import HTTPServer, SimpleHTTPRequestHandler
except ImportError:
    from http.server import BaseHTTPServer
    HTTPServer = BaseHTTPServer.HTTPServer

def up():
  thread.start()
  print('Starting server on port {}'.format(server.server_port))

def down():
  # will leave port x open but not server request
  # and die on main program's exit
  server.shutdown()
  print('Stopping server on port {}'.format(server.server_port))

port = 80
web_root = "/var/www/html"
server = HTTPServer(('0.0.0.0', port), functools.partial(SimpleHTTPRequestHandler, directory=web_root))
thread = threading.Thread(target = server.serve_forever)
thread.deamon = True