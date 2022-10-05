#include <SFML/Graphics.hpp>

int main() {
    sf::RenderWindow win(sf::VideoMode(600, 800), "test", sf::Style::Default);
    sf::CircleShape  circle(300.f);

    circle.setFillColor(sf::Color::Magenta);
    circle.setOutlineColor(sf::Color::Yellow);
    circle.setOutlineThickness(-30);

    while (win.isOpen()) {
        sf::Event e;

        while (win.pollEvent(e)) {
            switch (e.type) {
                case sf::Event::Closed:
                    win.close();
                    break;
            }
        }

        win.clear();
        win.draw(circle);
        win.display();
    }
}