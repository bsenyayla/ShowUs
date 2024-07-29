using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;

namespace CRCAPI.Services
{
    [ScopedDependency(ServiceType = typeof(IRepository<>))]
    public class Repository<TEntity> : IRepository<TEntity>
       where TEntity : class
    {

        protected readonly DbContext DbContext;
        protected readonly DbSet<TEntity> dbSet;

        public Repository(DbContext context)
        {
            DbContext = context ?? throw new ArgumentException(nameof(context));
            dbSet = DbContext.Set<TEntity>();
        }



        public virtual int Count(
            Expression<Func<TEntity, bool>> filter = null,
            string includeProperties = "")
        {
            IQueryable<TEntity> query = dbSet;

            if (filter != null)
            {
                query = query.Where(filter);
            }

            if (includeProperties != null)
            {
                foreach (var includeProperty in includeProperties.Split
                (new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    query = query.Include(includeProperty);
                }
            }

            return query.Count();
        }


        public virtual List<TEntity> List(
            Expression<Func<TEntity, bool>> filter = null,
            Func<IQueryable<TEntity>, IOrderedQueryable<TEntity>> orderBy = null,
            string includeProperties = "")
        {
            IQueryable<TEntity> query = dbSet;

            if (filter != null)
            {
                query = query.Where(filter);
            }

            if (includeProperties != null)
            {
                foreach (var includeProperty in includeProperties.Split
                (new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    query = query.Include(includeProperty);
                }
            }


            if (orderBy != null)
            {
                return orderBy(query).ToList();
            }
            else
            {
                return query.ToList();
            }
        }

        public virtual TEntity GetById(object id)
        {
            return dbSet.Find(id);
        }

        public virtual void Add(TEntity entity)
        {
            dbSet.Add(entity);
        }

        public virtual void AddRange(IEnumerable<TEntity> entities)
        {
            dbSet.AddRange(entities);
        }

        public virtual void RemoveRange(IEnumerable<TEntity> entities)
        {
            dbSet.RemoveRange(entities);
        }

        public virtual void Delete(object id)
        {
            TEntity entityToDelete = dbSet.Find(id);
            Delete(entityToDelete);
        }

        public virtual void Delete(TEntity entityToDelete)
        {
            if (DbContext.Entry(entityToDelete).State == EntityState.Detached)
            {
                dbSet.Attach(entityToDelete);
            }
            dbSet.Remove(entityToDelete);
        }

        public virtual void Update(TEntity entityToUpdate)
        {
            dbSet.Attach(entityToUpdate);
            DbContext.Entry(entityToUpdate).State = EntityState.Modified;
        }

    }
}
