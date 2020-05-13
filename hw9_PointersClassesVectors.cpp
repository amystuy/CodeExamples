/*
 *
 *  homework9
 
 *	This program uses pointers, classes, and vectors.
 *	It creates a vector of pointers to a class Person that has a name, a best friend,
 *  and a popularity counter. 
 *
 *  Created by Amy Stuyvesant on 3/12/13.
 *  Copyright 2013 __MyCompanyName__. All rights reserved.
 *
 */

#include <string>
#include <iostream>
#include <vector>
#include <time.h>
using namespace std;

//Class declaration
class Person
{
	public:
		Person ();
		Person (string n, Person *bf, int pop);
		string get_name();
		Person *get_best_friend();
		int get_popularity ();
	private:
		string name;
		Person *best_friend;
		int popularity;
};

//Class definitions
Person::Person ()
{
	name = "";
	best_friend = NULL;
	popularity = 0;
}

Person::Person (string n, Person *bf, int pop)
{
	name = n;
	best_friend = bf;
	popularity = pop;
}

string Person:: get_name()
{
	return name;
}

Person *Person:: get_best_friend()
{
	return best_friend;
}

int Person:: get_popularity()
{
	return popularity;
}


//Function prototypes
/*
-print function prints the contents of the vector list
-it takes on as arguments the vector list, passed by reference
-it does not return anything, just outputs the contents of the vector
*/
void print(vector <Person *> &list);

/*
-update returns the popularity integer
-it takes on the vector of pointers and a string
-it then searches for this string and updates a counter whenever the string is found as the best friend
-it does not update unless the string matches the BEST FRIEND name
*/
int update(vector <Person *> &list, string bf_name);

int main ()
{
	string answer;
	int pop = 0;
	vector <Person *> list;
	Person *p;
	Person *q;
	Person *r;
	
	//fill vector with pointers to people in Person class
	cout << "Hello! Begin by continually entering people's names with a return inbetween." << endl;
	cout << "You may type Q at any point to quit." << endl;
	while (true)
	{
		
		getline (cin, answer);
		if (answer == "Q" || answer == "q") break;
		
		p = new Person(answer, NULL, pop);
		list.push_back(p);
	}
	
	string name; //name of best friend
	
	//get best friend with new memory
	for (int i=0; i < list.size(); i++)
	{
		cout << "Who is the best friend of " << list[i] -> get_name() << "?" <<endl;
		getline (cin, name);
		
		
		q = new Person (name, NULL, pop);
		
		//set best friend 
		string n;
		n = list[i] -> get_name();
		
		r = new Person(n, q, pop);
		list[i] = r;
	}

	delete p;
	
	//update popularity
	for (int i=0; i<list.size(); i++)
	{
		string search = list[i] -> get_name();
		pop = update(list, search);
		
		Person *b;
		b = new Person(list[i] -> get_name(), list[i] -> get_best_friend(), pop);
		list[i] = b;
	}
	
	cout << "Here is the list of people, their best friend, and their popularity points: " << endl;
	cout << "\n";
	print(list);
	
	delete q;
	delete r;
	return 0;
	
}

//Function definitions
void print(vector < Person *> &list)
{
	for (int i=0; i < list.size(); i++)
	{
		cout << list[i] -> get_name() << ", ";
		cout << list[i] -> get_best_friend() -> get_name() << ", ";
		cout << list[i] -> get_popularity() << endl;
	}
}

int update(vector <Person *> &list, string bf_name)
{
	int count = 0;
	for (int i=0; i<list.size(); i++)
	{
		if (bf_name == list[i] -> get_best_friend() -> get_name())
		{
			count++;
		}
	}
	return count;
}




		