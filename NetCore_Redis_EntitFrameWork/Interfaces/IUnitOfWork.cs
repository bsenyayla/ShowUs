using Microsoft.EntityFrameworkCore;
using System;
using System.Transactions;

namespace CRCAPI.Services.Interfaces
{
    public interface IUnitOfWork : IDisposable
    {
        IRepository<TEntity> GetRepository<TEntity>() where TEntity : class;

        int SaveChanges();

        int SaveChangesByTransaction(TransactionScopeOption required = TransactionScopeOption.Required, IsolationLevel isolationLevel = IsolationLevel.ReadCommitted);
    }

    public interface IUnitOfWork<TContext> : IUnitOfWork where TContext : DbContext
    {
        TContext Context { get; }
    }
}
