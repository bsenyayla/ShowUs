using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;

namespace CRCAPI.Services.Interfaces
{
    public interface IRepository<TEntity> 
        where TEntity : class
    {
        List<TEntity> List(Expression<Func<TEntity, bool>> filter = null, Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> orderBy = null, string includeProperties = "");
        int Count(Expression<Func<TEntity, bool>> filter = null, string includeProperties = "");
        TEntity GetById(object id);
        void Add(TEntity entity);
        void AddRange(IEnumerable<TEntity> entities);
        void RemoveRange(IEnumerable<TEntity> entities);
        void Update(TEntity entityToUpdate);
        void Delete(TEntity entityToDelete);
        void Delete(object id);
    }
}