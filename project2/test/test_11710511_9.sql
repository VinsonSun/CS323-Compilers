int max(int a, int b) {
   if(a > b) {
      return a;
   } else {
      return b;
   }
}

int test9() {
   int a = 1;
   int b = 2;
   int c = 3;
   return max(a, b, c);
}
