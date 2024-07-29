using CRCAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Transactions;

namespace CRCAPI.Services
{
    //[ScopedDependency(ServiceType = typeof(IUnitOfWork<>))]
    public class UnitOfWork<TContext> : IUnitOfWork<TContext>, IUnitOfWork
        where TContext : DbContext, IDisposable
    {

        private Dictionary<Type, object> _repositories;
        public TContext Context { get; }

        public UnitOfWork(TContext context)
        {
            Context = context;
        }

        public IRepository<TEntity> GetRepository<TEntity>() where TEntity : class
        {
            if (_repositories == null) _repositories = new Dictionary<Type, object>();

            var type = typeof(TEntity);
            if (!_repositories.ContainsKey(type)) _repositories[type] = new Repository<TEntity>(Context);
            return (IRepository<TEntity>)_repositories[type];
        }

        public int SaveChanges()
        {
            return Context.SaveChanges();
        }

        public int SaveChangesByTransaction(TransactionScopeOption required = TransactionScopeOption.Required, IsolationLevel isolationLevel = IsolationLevel.ReadCommitted)
        {
            using (TransactionScope transactionScope = new TransactionScope(required, new TransactionOptions { IsolationLevel = isolationLevel }, TransactionScopeAsyncFlowOption.Enabled))
            {
                var saveChangeResponse = Context.SaveChanges();
                
                transactionScope.Complete();

                return saveChangeResponse;
            }
        }

        public void Dispose()
        {
            Context?.Dispose();
        }
    }
}
