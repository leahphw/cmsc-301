#include <iostream>

// Item class definition
class Item {
public:
    int goldValue;
    int attackBonus;
    int armorBonus;

    Item(int gv, int ab, int armb) {
        goldValue = gv;
        attackBonus = ab;
        armorBonus = armb;
    }

};

// Player class definition
class Player {
public:
    static const int INVENTORY_SIZE = 5;
    int max_hp;
    int current_hp;
    int gold;
    int strength;
    Item *equipped_item;
    Item *inventory[INVENTORY_SIZE];

    Player(int mh, int g, int s) {
        max_hp = mh;
        current_hp = mh; // Assuming current health starts at max
        gold = g;
        strength = s;
        equipped_item = nullptr;
        for (int i = 0; i < INVENTORY_SIZE; ++i) {
            inventory[i] = nullptr;
        }
    }

    virtual int attack() {
        return strength;
    }

    virtual void takeDamage(int damage) {
        current_hp -= damage;
        if (current_hp < 0) current_hp = 0;
    }

    virtual void sellItem(Item *item) {
        if (item == nullptr) return;

        for (int i = 0; i < INVENTORY_SIZE; ++i) {
            if (inventory[i] == item) {
                gold += item->goldValue;
                inventory[i] = nullptr; // Remove item from inventory
                break;
            }
        }
    }

    virtual int pickUpItem(Item *newItem) {
        for (int i = 0; i < INVENTORY_SIZE; ++i) {
            if (inventory[i] == nullptr) {
                inventory[i] = newItem;
                return 0;
            }
        }
        return -1; // Inventory is full
    }
};

// Merchant class definition
class Merchant : public Player {
public:

    Merchant(int mh, int g, int s)
        : Player(mh, g, s) {
        for (int i = 0; i < INVENTORY_SIZE; ++i) {
            inventory[i] = nullptr;
        }
    }

    void sellItem(Item *item) override {
        if (item == nullptr) return;

        for (int i = 0; i < INVENTORY_SIZE; ++i) {
            if (inventory[i] == item) {
                int sellPrice = 2 * item->goldValue;
                gold += sellPrice; // Merchant sells for double the value
                inventory[i] = nullptr; // Remove item from inventory
                break;
            }
        }
    }

    int pickUpItem(Item *newItem) override {
        for (int i = 0; i < INVENTORY_SIZE; ++i) {
            if (inventory[i] == nullptr) {
                inventory[i] = newItem;
                return 0;
            }
        }
        return -1; // Inventory is full
    }
};

// Warrior class definition
class Warrior : public Player {
public:
    Warrior(int mh, int g, int s)
        : Player(mh, g, s) {}

    int attack() override {
        // Warriors do extra damage with attackBonus.
        return equipped_item != nullptr ? strength + equipped_item->attackBonus : strength;
    }
};

// Knight class definition
class Knight : public Warrior {
public:
    Knight(int mh, int g, int s)
        : Warrior(mh, g, s) {}

    void takeDamage(int damage) override {
        // Knights take less damage based on armor. 
        if (equipped_item != nullptr) {
            damage -= equipped_item->armorBonus;
            if (damage < 0) damage = 0;
        }
        Player::takeDamage(damage);
    }
};

void testPlayer(Player* player) {
    // Give them some items
    Item* item1 = new Item(100, 5, 6);
    player->pickUpItem(item1);
    Item* item2 = new Item(120, 4, 8);
    player->pickUpItem(item2);

    // Equip an item
    player->equipped_item = player->inventory[0];

    // Attack
    int damage = player->attack();
    std::cout << damage << std::endl;

    // Take damage
    player->takeDamage(10);
    std::cout << player->current_hp << std::endl;

    // Sell item
    player->sellItem(item2);
    std::cout << player->gold << std::endl;
    
    // Newline
    std::cout << std::endl;
}

int main() {
    Player* player = new Player(100, 0, 5);
    Player* warrior = new Warrior(100, 0, 5);
    Player* knight = new Knight(100, 0, 5);
    Player* merchant = new Merchant(100, 0, 5);

    testPlayer(player);
    testPlayer(warrior);
    testPlayer(knight);
    testPlayer(merchant);

    return 0;
}