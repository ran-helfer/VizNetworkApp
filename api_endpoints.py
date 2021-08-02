from flask import Flask
from flask_restful import Resource, Api, reqparse
import pandas as pd
import ast
import csv
import os

app = Flask(__name__)
api = Api(app)

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
        print(persons)
        return {'persons': persons}, 200  # return data and 200 OK

    def post(self):
        parser = reqparse.RequestParser()  # initialize
        parser.add_argument('userId', required=True)  # add args
        parser.add_argument('name', required=True)
        parser.add_argument('city', required=True)
        args = parser.parse_args()  # parse arguments to dictionary
    
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

        return {'value': person}, 200  # return data with 200 OK

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

    def delete(self):
        parser = reqparse.RequestParser()  # initialize
        parser.add_argument('userId', required=True)  # add userId arg
        args = parser.parse_args()  # parse arguments to dictionary
        
        # read our CSV
        data = pd.read_csv('users.csv')
        
        if args['userId'] in list(data['userId']):
            # remove data entry matching given userId
            data = data[data['userId'] != args['userId']]
            
            # save back to CSV
            data.to_csv('users.csv', index=False)
            # return data and 200 OK
            return {'data': data.to_dict()}, 200
        else:
            # otherwise we return 404 because userId does not exist
            return {
                'message': f"'{args['userId']}' user not found."
            }, 404

                    
class Locations(Resource):
    def get(self):
        data = pd.read_csv('locations.csv')  # read local CSV
        return {'data': data.to_dict()}, 200  # return data dict and 200 OK
    
    def post(self):
        parser = reqparse.RequestParser()  # initialize parser
        parser.add_argument('locationId', required=True, type=int)  # add args
        parser.add_argument('name', required=True)
        parser.add_argument('rating', required=True)
        args = parser.parse_args()  # parse arguments to dictionary
        
        # read our CSV
        data = pd.read_csv('locations.csv')
    
        # check if location already exists
        if args['locationId'] in list(data['locationId']):
            # if locationId already exists, return 401 unauthorized
            return {
                'message': f"'{args['locationId']}' already exists."
            }, 409
        else:
            # otherwise, we can add the new location record
            # create new dataframe containing new values
            new_data = pd.DataFrame({
                'locationId': [args['locationId']],
                'name': [args['name']],
                'rating': [args['rating']]
            })
            # add the newly provided values
            data = data.append(new_data, ignore_index=True)
            data.to_csv('locations.csv', index=False)  # save back to CSV
            return {'data': data.to_dict()}, 200  # return data with 200 OK
    
    def patch(self):
        parser = reqparse.RequestParser()  # initialize parser
        parser.add_argument('locationId', required=True, type=int)  # add args
        parser.add_argument('name', store_missing=False)  # name/rating are optional
        parser.add_argument('rating', store_missing=False)
        args = parser.parse_args()  # parse arguments to dictionary
        
        # read our CSV
        data = pd.read_csv('locations.csv')
        
        # check that the location exists
        if args['locationId'] in list(data['locationId']):
            # if it exists, we can update it, first we get user row
            user_data = data[data['locationId'] == args['locationId']]
            
            # if name has been provided, we update name
            if 'name' in args:
                user_data['name'] = args['name']
            # if rating has been provided, we update rating
            if 'rating' in args:
                user_data['rating'] = args['rating']
            
            # update data
            data[data['locationId'] == args['locationId']] = user_data
            # now save updated data
            data.to_csv('locations.csv', index=False)
            # return data and 200 OK
            return {'data': data.to_dict()}, 200
        
        else:
            # otherwise we return 404 not found
            return {
                'message': f"'{args['locationId']}' location does not exist."
            }, 404
    
    def delete(self):
        parser = reqparse.RequestParser()  # initialize parser
        parser.add_argument('locationId', required=True, type=int)  # add locationId arg
        args = parser.parse_args()  # parse arguments to dictionary

        # read our CSV
        data = pd.read_csv('locations.csv')
        
        # check that the locationId exists
        if args['locationId'] in list(data['locationId']):
            # if it exists, we delete it
            data = data[data['locationId'] != args['locationId']]
            # save the data
            data.to_csv('locations.csv', index=False)
            # return data and 200 OK
            return {'data': data.to_dict()}, 200
        
        else:
            # otherwise we return 404 not found
            return {
                'message': f"'{args['locationId']}' location does not exist."
            }


api.add_resource(Users, '/users')  # add endpoints
api.add_resource(Locations, '/locations')

if __name__ == '__main__':
    app.run()  # run our Flask app
