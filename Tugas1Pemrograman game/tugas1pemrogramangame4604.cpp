#include <iostream>
#include <string>
#include <map>

using namespace std;

// Struktur untuk menyimpan status karakter
struct CharacterStatus {
    int hp;
    int mana;
    int damage;
    int sword;
};

// Class untuk mengelola item dan status karakter
class Character {
private:
    CharacterStatus status;
    map<string, int> items;

public:
    Character() {
        status = {100, 100, 20, 1}; // Status awal karakter
        items["hp potion"] = 3; // Menambah item dan stok awal
        items["mana potion"] = 2;
        items["sword"] = 1;
    }

    void displayStatus() {
        cout << "Character Status:" << endl;
        cout << "HP: " << status.hp << endl;
        cout << "Mana: " << status.mana << endl;
        cout << "Damage: " << status.damage << endl;
        cout << "Sword: " << status.sword << endl;

        cout << endl << "Inventory:" << endl;
        for (const auto& item : items) {
            cout << item.first << ": " << item.second << endl;
        }
    }

    void useItem(const string& item_name) {
        if (items.find(item_name) != items.end()) {
            if (item_name == "hp potion") {
                status.hp += 50;
                items[item_name]--;
                cout << "HP Potion used. HP increased by 50." << endl;
            } else if (item_name == "mana potion") {
                status.mana += 30;
                items[item_name]--;
                cout << "Mana Potion used. Mana increased by 30." << endl;
            } else if (item_name == "sword") {
                if (status.sword == 0) {
                    status.damage += 10;
                    status.sword++;
                    cout << "Equipped Sword. Damage increased by 10." << endl;
                } else {
                    cout << "You already have a sword equipped." << endl;
                }
            }
        } else {
            cout << "Item not found." << endl;
        }
    }

    void removeSword() {
        if (status.sword > 0) {
            status.damage -= 10;
            status.sword = 0;
            cout << "Sword removed. Damage decreased by 10." << endl;
        } else {
            cout << "No sword equipped." << endl;
        }
    }
};

int main() {
    Character player;

    player.displayStatus();

    cout << endl << "Using HP Potion..." << endl;
    player.useItem("hp potion");
    player.displayStatus();

    cout << endl << "Using Sword..." << endl;
    player.useItem("sword");
    player.displayStatus();

    cout << endl << "Removing Sword..." << endl;
    player.removeSword();
    player.displayStatus();

    return 0;
}
