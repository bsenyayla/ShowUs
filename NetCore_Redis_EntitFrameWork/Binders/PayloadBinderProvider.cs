using StandartLibrary.Models.ViewModels.Common;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using System;

namespace CRCAPI.Services.Binders
{
    /// <summary>
    /// Custom payload binder provider for .net core.
    /// </summary>
    public class PayloadBinderProvider : IModelBinderProvider
    {
        /// <summary>
        /// Binder creator and getter.
        /// </summary>
        /// <param name="context">Current conect of request.</param>
        /// <returns>Model binder object.</returns>
        public IModelBinder GetBinder(ModelBinderProviderContext context)
        {
            if (HasGenericTypeBase(context.Metadata.ModelType, typeof(Payload<>))
                || context.Metadata.ModelType == typeof(Payload)
                || IsExtendedFromPayload(context.Metadata.ModelType))
            {
                return new PayloadBinder();
            }

            return null;
        }


        /// <summary>
        /// Payload can be generic type container.
        /// </summary>
        /// <param name="type">Object type.</param>
        /// <param name="genericType">Generic object type.</param>
        /// <returns>If payload generic type container it returns true.</returns>
        private bool HasGenericTypeBase(Type type, Type genericType)
        {
            if (type.IsConstructedGenericType && type.GetGenericTypeDefinition() == genericType)
            {
                return true;
            }

            return false;
        }

        private bool IsExtendedFromPayload(Type type)
        {
            if (type.IsSubclassOf(typeof(Payload)) || type.IsSubclassOf(typeof(Payload<>)))
            {
                return true;
            }
            return false;
        }
    }
}
