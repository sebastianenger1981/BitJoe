package org.bushe.swing.event.generics;

import java.lang.reflect.Type;
import java.lang.reflect.Constructor;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.InvocationTargetException;

/**
 * Courtesy of Neil Gafter's blog.
 * Thanks to Curt Cox for the pointer.
 */
public abstract class TypeReference<T> {

 private final Type type;
 private volatile Constructor<?> constructor;

 protected TypeReference() {
     Type superclass = getClass().getGenericSuperclass();
     if (superclass instanceof Class) {
         throw new RuntimeException("Missing type parameter.");
     }
     this.type = ((ParameterizedType) superclass).getActualTypeArguments()[0];
 }

 /**
  * Instantiates a new instance of {@code T} using the default, no-arg
  * constructor.
  */
 @SuppressWarnings("unchecked")
 public T newInstance()
         throws NoSuchMethodException, IllegalAccessException,
         InvocationTargetException, InstantiationException {
     if (constructor == null) {
         Class<?> rawType = type instanceof Class<?>
             ? (Class<?>) type
             : (Class<?>) ((ParameterizedType) type).getRawType();
         constructor = rawType.getConstructor();
     }
     return (T) constructor.newInstance();
 }

 /**
  * Gets the referenced type.
  */
 public Type getType() {
     return this.type;
 }
}

