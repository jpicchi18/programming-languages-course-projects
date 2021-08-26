import sys
import aiohttp
import asyncio
import util         # credit to Jason Jewik from Piazza for this file
import time
import json
import re
import logging

'''
my ports: 12570 through 12574
'''
port_offset = {'Riley':0, 'Jaquez':1, 'Juzang':2, 'Campbell':3, 'Bernard':4}
base_port = 12570
API_KEY = 'AIzaSyAxvKjrbI1EWx0pfpQAHDi3ze4ggLcf5aE'
connections = {
    'Riley' : ['Juzang', 'Jaquez'],
    'Jaquez' : ['Riley', 'Bernard'],
    'Bernard' : ['Jaquez', 'Juzang', 'Campbell'],
    'Juzang' : ['Riley', 'Bernard', 'Campbell'],
    'Campbell' : ['Juzang', 'Bernard']
}
localhost = '127.0.0.1'

def exit(msg:str):
    print(msg, file=sys.stderr)
    sys.exit(1)

# CREDIT: for the concept of the server class and ideas about the functionality
#  of each member function, credit is given to the TA cs_131 github
class Server:
    def __init__(self, name):
        if not (name in port_offset.keys()):
            exit("server.py error: server name must be Riley, Jaquez, Juzang, Campbell, Bernard")

        self.name = name
        self.port = base_port + port_offset[name]
        self.ip = '127.0.0.1'
        self.at_msgs = {}   # each element is a tuple (AT_msg, latitude, longitude)
        self.shutdown = False
        self.friends = connections[name]

        logging.basicConfig(filename="{0}.log".format(self.name), level=logging.INFO, \
            format='%(message)s', filemode="w+")
        logging.info("START-UP: server '{0}' started up.".format(self.name))

    async def get_ports(self):
        async with aiohttp.ClientSession() as session:
            params = [('uid', '605124511')]
            async with session.get('https://cs131portserver-314508.wl.r.appspot.com/', params=params) as resp:
                  print(await resp.text())

    def invalid_command(self, msg:str) -> str:
        return "? " + msg

    def valid_timestamp(self, tm:str) -> bool:
        try:
            # check that timestamp is a float
            float(tm)

            # TODO: check decimal places
        except:
            return False

        return True

    async def parse_IAMAT(self, msg:str) -> str:
        elements = msg.split()

        # make sure all fields are there
        if (len(elements) != 4):
            return self.invalid_command(msg)

        # extract coordinates
        try:
            lat, long = util.extract_coords(elements[2])
        except ValueError:
            return self.invalid_command(msg)

        # check that time field is in POSIX format
        if (not self.valid_timestamp(elements[3])):
            return self.invalid_command(msg)

        # create the return message
        current_time = float("{:.9f}".format(time.time()))
        sign = "+"
        if (current_time < float(elements[3])):
            sign = "-"

        return_msg = "AT {server_name} {sign}{time_diff} {ID} {coords} {timestamp}".format(
            server_name = self.name,
            sign = sign,
            time_diff = "{:.9f}".format(abs(current_time - float(elements[3]))),
            ID = elements[1],
            coords = elements[2],
            timestamp = elements[3]
        )

        # add message to our dictionary
        # await self.flood(return_msg)
        await self.flood(return_msg)

        return return_msg

    # CREDIT: for this function, credit is given to TA cs_131 github hint code
    async def get_JSON(self, radius, bound, latitude, longitude) -> str:
        '''
        raises ValueError if it fails
        '''
        try:
            radius = radius * 1000   # convert to km meters
            loc = "{0},{1}".format(latitude, longitude)
            url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?key={0}&location={1}&radius={2}'.format(API_KEY, loc, radius)
            response = None

            async with aiohttp.ClientSession(connector=aiohttp.TCPConnector(ssl=False,),) as session:
                async with session.get(url) as resp:
                    response = await resp.json()     # response is now a dictionary object
            
            # enforce the information bound
            response['results'] = response['results'][:bound]

            # convert to string
            response_string = json.dumps(response, indent=4)

            # replace any sequence of 2+ newlines with a single newline
            response_string = re.sub("\n+", "\n", response_string)

            # all trailing newlines are removed, followed by 2 newlines added back
            response_string = response_string.rstrip("\n") + "\n\n"

            return response_string
        except: 
            raise ValueError

    async def parse_WHATSAT(self, msg:str) -> str:
        elements = msg.split()

        # always has 4 fields
        if (len(elements) != 4):
            return self.invalid_command(msg)
        
        # extract id
        id = elements[1]

        # extract radius
        try:
            # extract radius
            rad = int(elements[2])
            if (rad < 0 or rad > 50):
                raise ValueError

            # extract bound
            bound = int(elements[3])
            if (bound < 0 or bound > 20):
                raise ValueError

            # get at message
            at_msg = self.at_msgs[id]

            # get coords from at message
            at_elements = at_msg.split()
            latitude, longitude = util.extract_coords(at_elements[4])

            # query google places
            json_output = await self.get_JSON(rad, bound, latitude, longitude)

            # return final string
            return at_msg + "\n" + json_output
        except:
            return self.invalid_command(msg)

    async def process_message(self, msg:str) -> str:
        '''
        returns the message to send back to client
        '''
        elements = msg.split()

        if (elements[0] == "IAMAT"):
            # parse command
            return await self.parse_IAMAT(msg)

        elif (elements[0] == "WHATSAT"):
            return await self.parse_WHATSAT(msg)

        elif (elements[0] == "AT"):
            return await self.parse_AT(msg)
        
        else:
            return self.invalid_command(msg)

    async def flood(self, msg:str):
        elements = msg.split()
        new_time = elements[5]
        old_msg_elements = None
        old_time = None
        if (elements[3] in self.at_msgs.keys()):
            old_msg_elements = self.at_msgs[elements[3]].split()
            old_time = old_msg_elements[5]

        # if message is in our dictionary already, or if message is
        #  older than the message in our dictionary, then don't propagate
        if (old_msg_elements and \
            ((self.at_msgs[elements[3]] == msg) or (new_time < old_time))):
            return

        # else, we add to our dictionary and propagate
        self.at_msgs[elements[3]] = msg

        for friend in self.friends:
            try:
                # connect to friend server
                port_num = base_port + port_offset[friend]
                reader, writer = await asyncio.open_connection(localhost, port_num)

                # send message
                writer.write(msg.encode())
                writer.write_eof()
                await writer.drain()
                writer.close()
                await writer.wait_closed()
                
                # log transaction
                logging.info("CONNECTED to server '{0}' AND PROPAGATED: '{1}'.".format(friend, msg))
            except:
                logging.info("CONNECTION FAILED: failed to connect to server '{0}' to propagate '{1}'.".format(friend, msg))
                pass

    async def parse_AT(self, msg:str) -> str:
        elements = msg.split()

        try:
            if (len(elements) != 6):
                raise ValueError
            
            # check for valid server name
            if (elements[1] not in connections.keys()):
                raise ValueError

            # check for POSIX time difference
            if (not self.valid_timestamp(elements[2][1:])):
                raise ValueError

            # check for coords
            util.extract_coords(elements[4])

            # check for timestamp
            if (not self.valid_timestamp(elements[5])):
                raise ValueError

            # passed all checks, so propagate the message
            await self.flood(msg)

            return ""

        except:
            return self.invalid_command(msg)

    async def handle_request(self, reader, writer):
        # get message from client
        data = await reader.read()
        msg = data.decode()
        logging.info("RECIEVED: '{0}'".format(msg))

        # parse the message
        msg_back = await self.process_message(msg)
        
        if msg_back:
            writer.write(msg_back.encode())
            await writer.drain()
            logging.info("SENT BACK: '{0}'".format(msg_back))

        writer.close()
        await writer.wait_closed()

    async def shutdown(self):
        if not self.shutdown:
            self.server.close()  
            self.shutdown = True  
            logging.info("SHUTDOWN: server '{0}' has shutdown.".format(self.name))
    
    async def run_forever(self):
        self.shutdown = False
        self.server = await asyncio.start_server(self.handle_request, host=self.ip, port=self.port)
        await self.server.serve_forever()

        self.shutdown()


# CREDIT: to the TA CS 131 github for the structure of this "main" function logic
def main():
    # get CL parameters
    if (len(sys.argv) != 2):
        exit("server.py error: must pass 2 parameters")

    server_name = sys.argv[1]
    if (server_name not in port_offset.keys()):
        exit("server.py error: server name must be 'Riley', 'Campbell', 'Juzang', \
        'Jaquez', or 'Bernard'")

    # start up the server
    server = Server(server_name)

    try:
        asyncio.run(server.run_forever())
    except KeyboardInterrupt:
        server.shutdown()

if __name__ == '__main__':
    main()