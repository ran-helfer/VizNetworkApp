from flask import Flask, request
from flask_restful import Resource, Api, reqparse
import pandas as pd
import ast
import csv
import os
from time import sleep
import sys

app = Flask(__name__)
api = Api(app)

SLEEP_TIME = int(1)

if(len(sys.argv)>=2):
    SLEEP_TIME = int(sys.argv[1])

class Users(Resource):

    def get(self):
        persons = []
        with open('users.csv', 'r') as f:
            reader = csv.reader(f)
            count = 0
            for row in reader:
                if count==0:
                    count = 1
                    continue
                
                persons.append({'userId': row[0],
                                'name': row[1],
                                'city': row[2]})
        #print(persons)
        return {'users': persons}, 200  # return data and 200 OK

    def post(self):
        parser = reqparse.RequestParser()  # initialize
        parser.add_argument('userId', required=True)  # add args
        parser.add_argument('name', required=True)
        parser.add_argument('city', required=True)
        args = parser.parse_args()  # parse arguments to dictionary
    
        sleep(SLEEP_TIME)
        # read our CSV
        users_file = 'users.csv'
        with open(users_file, 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                print(args['userId'])
                print(row[0])
                if args['userId']==row[0].replace(" ", ""):
                    print('user already exists ! aborting')
                    return {
                        'message': f"'{args['userId']}' already exists."
                    }, 409
                    return
        
        # create new dataframe containing new values
        person = []
        person.append({'userId': row[0],
                        'name': row[1],
                        'city': row[2]})
    
        tmp_file_name = 'users_tmp.csv'

        with open(tmp_file_name, 'w', newline='') as csvfile:
            fieldnames = ['userId', 'name', 'city']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

            writer.writerow({'userId': args['userId'], 'name': args['name'],'city': args['city']})
        os.system("cat users_tmp.csv >> users.csv ")
        os.system('rm users_tmp.csv')

        return {'data': person}, 200  # return data with 200 OK

    def put(self):
        parser = reqparse.RequestParser()  # initialize
        parser.add_argument('userId', required=True)  # add args
        parser.add_argument('location', required=True)
        args = parser.parse_args()  # parse arguments to dictionary

        # read our CSV
        data = pd.read_csv('users.csv')
        
        if args['userId'] in list(data['userId']):
            # evaluate strings of lists to lists !!! never put something like this in prod
            data['locations'] = data['locations'].apply(
                lambda x: ast.literal_eval(x)
            )
            # select our user
            user_data = data[data['userId'] == args['userId']]

            # update user's locations
            user_data['locations'] = user_data['locations'].values[0] \
                .append(args['location'])
            
            # save back to CSV
            data.to_csv('users.csv', index=False)
            # return data and 200 OK
            return {'data': data.to_dict()}, 200

        else:
            # otherwise the userId does not exist
            return {
                'message': f"'{args['userId']}' user not found."
            }, 404


class UsersDelete(Resource):
    def delete(self, user_id):
        
        # read our CSV
        data = pd.read_csv('users.csv')

        os.system('cat users.csv | grep %s > check_if_there_is_a_user.txt'  % (user_id))
        
        user_exist_file = open('check_if_there_is_a_user.txt' ,'r')
   
        found_user = False
        while True:
            line = user_exist_file.readline()
            if not line:
                break
                
            found_user = True
            break
        
        if found_user == False:
            return {
                'message': f"'{user_id}' user not found."
            }, 405

        # read our CSV
        os.system('cat users.csv | grep -v %s >> tmp_users.csv'  % (user_id))
        os.system('rm check_if_there_is_a_user.txt')
        os.system('mv tmp_users.csv users.csv')
        os.system('rm tmp_users.csv')

        return {'message': 'ok'}, 200


    

api.add_resource(Users, '/users')
api.add_resource(UsersDelete, '/users/<string:user_id>')

if __name__ == '__main__':
    app.run()  # run our Flask app
