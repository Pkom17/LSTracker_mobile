import 'package:flutter/material.dart';
import '../widgets/conveyoraction.dart';
import '../widgets/laboratoryaction.dart';
import '../widgets/settings_dashboard.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.white10, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(
                    "assets/images/mshp.jpg",
                  ),
                  radius: 40,
                ),
                SizedBox(width: 10),
                Text(
                  "LSTRACKER",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delivery_dining_outlined,
              size: 22,
              color: Colors.green,
            ),
            title: Text(
              "Convoyeur",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ConvoyeurView()));
            },
          ),
          Divider(
            color: const Color.fromARGB(255, 183, 181, 181),
            indent: 2,
            endIndent: 2,
            thickness: 1,
            height: 1,
          ),
          ListTile(
            leading: Icon(
              Icons.local_hospital_outlined,
              size: 22,
              color: Colors.green,
            ),
            title: Text(
              "Laboratoire",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Laboratoryaction()));
            },
          ),
          Divider(
            color: const Color.fromARGB(255, 183, 181, 181),
            indent: 2,
            endIndent: 2,
            thickness: 1,
            height: 1,
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 22,
              color: Colors.green,
            ),
            title: Text(
              "Paramètres",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                  ),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsDashboard()));
            },
          )
        ],
      ),
    );
  }
}
