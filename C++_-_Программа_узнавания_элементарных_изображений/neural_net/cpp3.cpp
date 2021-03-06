#include <iostream.h>
#include <fstream.h>
#include <stdlib.h>

void fill(double array[289][25])
{
	for(int i=0;i<289;i++)
	{
		for(int j=0;j<25;j++)
		{
			array[i][j] = double(rand())/double(RAND_MAX);
		}
	}
}

int get_max(double array[25])
{
	double max=0.0;
	int address=0;
	for(int i=0;i<25;i++)
	{
		if(max < array[i])
		{
			max=array[i];
			address=i;
		}
	}
	array[address]=-8888.88;

	for(int i=0;i<25;i++)
	{
		if(i!=address && array[i]>=0)
			array[i]=0.0;
	}
	return address;
}

void main()
{
	
	int input[289];
	int output[289];
	double w1[289][25];
	double w2[25][289];
	double hidden[25];
	char next;
	ifstream fin;
	char filename[200];
	cout << "Enter file name to learn: ";
	cin >> filename;
	fin.open(filename);

	int i=0;
	int j=0;
	
	
	int lines=1;
	fin.get(next);
	while(lines != 18 )
	{
		if(next=='\n')
		{			
			lines++;
		}
		else
		{			
			if(next == '*')
				input[i]=1;
			else
				input[i]=0;
			i++;
		}
		fin.get(next);
	}

	for(i=0;i<289;i++)
		output[i]=input[i];
	for(i=0;i<289;i++)
	{
		if(i%17==0)
		{
			cout << endl;
		}
		else
			cout << output[i];
	}
	cout << "\n" << endl;

	
	for(i=0;i<25;i++)
	{
		for(j=0;j<289;j++)
			w2[i][j] = 0.0;
	}

	fill(w1);

	for(i=0;i<25;i++)
		hidden[i]=0.0;
	
	/************************************/
	for(i=0;i<289;i++)
	{
		for(j=0;j<25;j++)
		{
			hidden[j] += input[i]*w1[i][j];
			//cout << hidden[j] << endl;
		}
	}
	int max = get_max(hidden);

	
	for(i=0;i<289;i++)
	{
		if(input[i]==1)
		{
			w2[max][i] = 1;
			w1[i][max]=1;
		}
		else
		{
			w2[max][i] = 0;
			w1[i][max]=0;
		}

	}
	/****************************************/

	for(i=0;i<289;i++)
	{
		input[i]=0;
		output[i]=0;
	}
	/***************************************/
	
	ifstream fin1;
	cout << "Enter file name to learn: ";
	cin >> filename;
	fin1.open(filename);

	lines=1;
	fin1.get(next);
	i=0;
	while(lines != 18 )
	{
		if(next=='\n')
		{			
			lines++;
		}
		else
		{
			if(next == '*')
				input[i]=1;
			else
				input[i]=0;
			i++;
		}
		fin1.get(next);
	}

	for(i=0;i<289;i++)
		output[i]=input[i];

	for(i=0;i<289;i++)
	{
		if(i%17==0)
		{
			cout << endl;
		}
		else
			cout << output[i];
	}

	cout << "\n" << endl;

	
	
	for(i=0;i<289;i++)
	{
		for(j=0;j<25;j++)
		{
			hidden[j] += input[i]*w1[i][j];
		}
	}
	max = get_max(hidden);
	
	for(i=0;i<289;i++)
	{
		if(input[i]==1)
		{
			w2[max][i] = 1;
			w1[i][max]=1;
		}
		else
		{
			w2[max][i] = 0;
			w1[i][max]=0;
		}

	}

	for(i=0;i<289;i++)
	{
		input[i]=0;
		output[i]=0;
	}


	for(i=0;i<25;i++)
		hidden[i]=0.0;
	
	ifstream fin2;
	cout << "Enter file name to recognize: ";
	cin >> filename;
	fin2.open(filename);

	lines=1;
	fin2.get(next);
	i=0;
	while(lines != 18 )
	{
		if(next=='\n')
		{			
			lines++;
		}
		else
		{			
			if(next == '*')
				input[i]=1;
			else
				input[i]=0;
			i++;
		}
		fin2.get(next);
	}

	for(i=0;i<289;i++)
		output[i]=input[i];
	for(i=0;i<289;i++)
	{
		if(i%17==0)
		{
			cout << endl;
		}
		else
			cout << output[i];
	}

	for(i=0;i<289;i++)
	{
		for(j=0;j<25;j++)
		{
			hidden[j] += input[i]*w1[i][j];
		}
	}

	max = get_max(hidden);

	cout << "\n\nRecognized as: " << endl;

	for(i=0;i<289;i++)
	{
		output[i]=w2[max][i];
	//	cout << w2[max][i] << endl;
	}

	for(i=0;i<289;i++)
	{
		if(i%17==0)
		{
			cout << endl;
		}
		else
			cout << output[i];
	}


	
}


