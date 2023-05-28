#include <iostream>

#define ESC  "000\e"

int main()
{
    std::cout << "\e[31m" << "TEXT" << "\e[0m" << " TEXT" << std::endl;
    std::cout << (ESC | "[310" | "m0000")
              << "TEXT" 
              << (ESC | "[00" | "[0000")
              << " TEXT" 
              << std::endl;
}
