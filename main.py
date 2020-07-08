#!/usr/bin/python3

# sources used:
# https://github.com/JiayangWu/codewars-solutions-in-python/blob/master/010-6kyu-Clock%20in%20Mirror.py
# https://stackoverflow.com/questions/6808064/parsing-hhmm-in-python
# https://blog.miguelgrinberg.com/post/designing-a-restful-api-with-python-and-flask

from flask import Flask, jsonify, request

def realTime(mirrorTime):
    hour = int(mirrorTime[:-3]) # use this instead of [0:2] to handle only single digit hour cases
    minute = int(mirrorTime[-2:])

    clock = ""

    if hour < 11:
      real_hour = 11 - hour
    else:
      real_hour = 23 - hour # use the 12 hour clock format

    real_minute = 60 - minute
    if real_minute == 60:   # edge case for 00 minutes
      real_minute -=60
      real_hour += 1

    if real_hour > 12:  # PM to AM format conversion
      real_hour -=12
    
    if real_hour > 9 :
      clock = str(real_hour) + ':'
    else:
      clock = '0' + str(real_hour) + ':'    # concatenate starting 0 for single digit hours
    
    if real_minute > 9:
      clock += str(real_minute)
    else:
      clock += '0' + str(real_minute)   # concatenate starting 0 for single digit minutes
    return clock

app = Flask(__name__)

@app.route('/mirror_clock/api/v1.0/convert', methods=['POST'])
def get_time():
    if not request.json or not 'time' in request.json:  # check for request type json and time key
        abort(400)
    return jsonify({'time': realTime(request.json['time'])}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
