#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
using namespace std;

#include "csvFunctions.h"

vector<vector<double> > readCSV(std::string filename) {
	ifstream in(filename);
	vector<vector<double> > fields;
	if (in) {
		string line;
		while (getline(in, line)) {
			stringstream sep(line);
			string field;
			fields.push_back(vector<double>());
			while (getline(sep, field, ',')) {
				fields.back().push_back(stod(field));
			}
		}
	}
	for(int i = 0; i < fields.size(); i++) {
		for(int j = 0; j < fields[i].size(); j++) {
   			cout << fields[i][j] << ' ' ;
		}
		cout << "\n";
	}
	return(fields);
}
