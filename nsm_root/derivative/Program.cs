using System;
using parserDecimal.Parser;

namespace derivative
{
    class Program
    {
        static void Main(string[] args) // string type parameters  
        {  
            Derivative der = new Derivative();
            Console.WriteLine(der.ReturnDerivative(args[0]));

        }  
    }
}
