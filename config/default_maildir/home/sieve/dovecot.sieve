require ["fileinto"];

# rule:[Spam]
if anyof (header :is "X-Spam-Flag" "YES")
{
        fileinto "Spam";
        stop;
}
