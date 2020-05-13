/*
 *  hw8.cpp
 *  homework8
 *
 *  This assignment serves to create two matrices and add them.
 *  For each step, the user is asked if they would like to fill from a file/output to a file.
 *  It is assumed that the ints for the matrix are between -10 and 10.
 *
 *  Created by Amy Stuyvesant on 3/4/13.
 *  Copyright 2013 __MyCompanyName__. All rights reserved.
 *
 */


#include <iostream>
#include <time.h>
#include <string>
#include <iomanip>
#include <fstream>
using namespace std;

//Function prototypes

//1. fills a single matrix with random numbers
void rands(int matrix[][10], int rows, int columns);

//2. outputs a single matrix to the console
void print (int matrix [][10], int rows, int columns);

//3. adds two matrices
void add_matrices(int matrix1[][10], int row1, int column1, int matrix2[][10], int row2, int column2);

//4. fills a single matrix with values from a file
void fill_file(int matrix[][10], int rows, int columns, ifstream &fin);

//5. outputs a single matrix to a file
void output_file(int matrix[][10], int rows, int columns, ofstream &fout);

//6. add matrices but output to a file, not the console
void addition_to_file(int matrix1[][10], int row1, int column1, int matrix2[][10], int row2, int column2, ofstream &fout);



int main ()
{
	srand((int)time(0));
	int matrix1 [10][10];
	int matrix2 [10][10];
	
	int row1, row2;
	int column1, column2;
	string file;
	
	ifstream fin;
	ofstream fout;
	
	//Ask for rows and columns and check validity, make it so that it only asks for wrong one again, not all
	
	cout << "Please enter a valid number of rows for the first matrix." << endl;
	cin >> row1;
	while (row1 > 10 || row1 < 1)
	{
		cout << row1 << " is not a valid entry. Please re-enter a new row number" << endl;
		cin >> row1;
	}
	
	cout << "Please enter a valid number of columns for the first matrix." << endl;
	cin >> column1;
	while (column1 > 10 || column1 < 1)
	{
		cout << column1 << " is not a valid entry. Please re-enter a new column number" << endl;
		cin >> column1;
	}
	
	cout << "Please enter a valid number of rows for the second matrix." << endl;
	cin >> row2;
	while (row2 > 10 || row2 < 1)
	{
		cout << row2 << " is not a valid entry. Please re-enter a new row number" << endl;
		cin >> row2;
	}
	
	cout << "Please enter a valid number of columns for the second matrix." << endl;
	cin >> column2;
	while (column2 > 10 || column2 < 1)
	{
		cout << column2 << " is not a valid entry. Please re-enter a new column number" << endl;
		cin >> column2;
	}
	
	//Determine if file is used or not for filling
	string answer;
	string file_answer;
	cout << "Would you like to fill the matrices from a file? Y/N" << endl;
	cin >> answer;
	//If yes, fill from file
	if (answer == "Y" || answer == "y")
	{ 
		cout << "What is the name of your file?" << endl;
		cin >> file; 
	
		fin.open(file.c_str());

		fill_file(matrix1, row1, column1, fin);
		fill_file(matrix2, row2, column2, fin);
	}
	//if no, fill from random files
	else
	{
		rands (matrix1, row1, column1);
		rands (matrix2, row2, column2);
	}
		
	//determine if file is used for output	
	cout << "Would you like to output these matrices to a file? Y/N" << endl;
	cin >> answer;
	
	if (answer == "Y" || answer == "y")
	{
		cout << "What is the name of the file?" << endl;
		cin >> file;
			
		fout.open(file.c_str());
			
		output_file(matrix1, row1, column1, fout);
		output_file(matrix2, row2, column2, fout);
	}
	
	else
	{
		cout << "Matrix one is:" << endl; 
		print (matrix1, row1, column1);
		cout << endl;
		cout << "Matrix two is:" << endl;
		print (matrix2, row2, column2);
	}
	//Check to see if they want sum output to file
	string add_answer;
	cout << "Would you like the sum to be output to a file? Y/N" << endl;
	cin >> answer;
		
	if (answer == "Y" || answer == "y")
	{
		cout << "What is the file name?" << endl;
		cin >> file;
		fout.open(file.c_str());
		addition_to_file(matrix1, row1, column1, matrix2, row2, column2, fout);
	}
	
	else
	{
		cout << "The sum is: " <<endl;
		add_matrices(matrix1, row1, column1, matrix2, row2, column2);
	}
	
	system("pause");
	return 0;
}

//Function definitions:

void rands(int matrix[][10], int rows, int columns)
{	
	for (int i = 0; i < rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			matrix[i][j] = (rand () % 20 - 10, rand () % 20 - 10);
		}
	}
}

void print (int matrix [][10], int rows, int columns)
{
	cout << fixed << setprecision(0);
	for (int i = 0; i <  rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			cout << setw(5) << matrix[i][j];
		}
			cout << endl;
	}
}

void add_matrices(int matrix1[][10], int row1, int column1, int matrix2[][10], int row2, int column2)
{
	int matrix3[10][10];
	cout << fixed << setprecision(0);
	for (int i = 0; i <  row1; i++)
	{
		for (int j = 0; j < column1; j++)
		{
			matrix3[i][j] = matrix1[i][j] + matrix2[i][j];
			cout << setw(5) << matrix3[i][j];
		}
			cout << endl;
	}
			
}

void fill_file(int matrix[][10], int rows, int columns, ifstream &fin)
{
		
	for (int i = 0; i < rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			fin >> matrix[i][j];
		}	
	}
}

void output_file(int matrix[][10], int rows, int columns, ofstream &fout)
{	
	cout << fixed << setprecision(0);
	for (int i = 0; i <  rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			fout << setw(5) << matrix[i][j];
		}
			fout << endl;
	}
}

void addition_to_file(int matrix1[][10], int row1, int column1, int matrix2[][10], int row2, int column2, ofstream &fout)
{
	int matrix3[10][10];
	cout << fixed << setprecision(0);
	for (int i = 0; i <  row1; i++)
	{
		for (int j = 0; j < column1; j++)
		{
			matrix3[i][j] = matrix1[i][j] + matrix2[i][j];
			fout << setw(5) << matrix3[i][j];
		}
			fout << endl;
	}
			
}