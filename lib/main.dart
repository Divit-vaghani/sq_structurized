import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:sqf_demo/app_database/app_database.dart';
import 'package:sqf_demo/model/user_information.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sqflite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AppDataBase appDataBase = AppDataBase();
  final Faker faker = Faker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              await appDataBase.insert(
                UserInformation(
                  name: faker.person.name(),
                  lastName: faker.person.lastName(),
                  education: faker.company.position(),
                  address: faker.address.streetAddress(),
                  country: faker.address.country(),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<UserInformation>>(
        future: appDataBase.query(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!
                  .map(
                    (element) => ExpansionTile(
                      initiallyExpanded: true,
                      title: Text('${element.name} ${element.lastName}'),
                      trailing: IconButton(
                        onPressed: () async {
                          await appDataBase.delete(data: element.id);
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete),
                      ),
                      children: [
                        ListTile(title: Text('Address : ${element.address}')),
                        ListTile(title: Text('Country : ${element.country}')),
                        ListTile(
                            title: Text('Education : ${element.education}')),
                      ],
                    ),
                  )
                  .toList(),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
