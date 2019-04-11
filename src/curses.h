/* This header file describes the subset of the curses interface being used by this program.
 *
 * This file is then used to generate an SML interface using ml-nlffigen. For some reason
 * ml-nlffigen runs into errors when run on the *official* ncurses.h, so this file is a much
 * simpler version only describing the end-user interface to the dynamic library needed by the program.
 */

typedef char bool;

/* Control functions
 */
void *initscr();
int endwin();

int refresh();

int cbreak();
int nocbreak();
int echo();
int noecho();
int keypad(void *win, bool bf);

int curs_set(int visibility);

/* Output functions
 */
int printw(const char *fmt); // NLFFI Does not support variadic arguments, so they are not included in this signature

/* Input functions
 */
int getch();
