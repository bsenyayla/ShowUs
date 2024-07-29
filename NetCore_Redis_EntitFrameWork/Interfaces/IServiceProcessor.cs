using StandartLibrary.Models.ViewModels;
using System;
using System.Runtime.CompilerServices;

namespace CRCAPI.Services.Interfaces
{
    public interface IServiceProcessor
    {
        ServiceResponse Call<T, TResult>(Func<T, TResult> action, T parameter, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0);

        ServiceResponse Call<TResult>(Func<TResult> action, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0);

        ServiceResponse Call<T>(Action<T> action, T parameter, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0);

        ServiceResponse Call(Action action, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0);
        ServiceResponse Create<T>(T parameter, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0);
        ServiceResponse Call<T1, T2, TResult>(Func<T1, T2, TResult> action, T1 parameter, T2 parameter2, [CallerMemberName] string memberName = "", [CallerFilePath] string sourceFilePath = "", [CallerLineNumber] int sourceLineNumber = 0);
    }

}
