/******************************************************************************

    Contains mixin with `loadCopy` implementation that is shared by contiguous
    version handling decorators.

    Copyright:
        Copyright (c) 2009-2016 dunnhumby Germany GmbH.
        All rights reserved.

    License:
        Boost Software License Version 1.0. See LICENSE_BOOST.txt for details.
        Alternatively, this file may be distributed under the terms of the Tango
        3-Clause BSD License (see LICENSE_BSD.txt for details).

*******************************************************************************/

deprecated module ocean.util.serialize.contiguous.model.LoadCopyMixin;

/*******************************************************************************

    Params:
        exception_field = host member field with VersionHandlingException
            instance

*******************************************************************************/

template LoadCopyMethod(alias exception_field)
{
    /***************************************************************************

        Loads versioned struct from `buffer` and stores resulting data
        in `copy_buffer`, leaving `buffer` untouched.

        If deserialized struct is of different version than requested one,
        converts it iteratively, one version increment/decrement at time.

        Params:
            buffer = data previously generated by `store` method, contains both
                version data and serialized struct. Effectively const
            copy_buffer = buffer where deserialized struct data will be stored.
                Will be extended if needed and won't contain version bytes

        Returns:
            slice of `buffer` after deserialization and version stripping

    ***************************************************************************/

    public Contiguous!(S) loadCopy(S)(in void[] buffer, ref Contiguous!(S) copy_buffer)
    {
        static assert (
            Version.Info!(S).exists,
            "Trying to use " ~ This.stringof ~ " with unversioned struct "
                ~ S.stringof
        );

        exception_field.enforceInputLength!(S)(buffer.length);

        Version.Type input_version;
        auto unversioned = Version.extract(buffer, input_version);
        copy_buffer.data.length = unversioned.length;
        enableStomping(copy_buffer.data);
        copy_buffer.data[0 .. unversioned.length] = unversioned[];

        return this.handleVersion!(S)(copy_buffer.data, input_version);
    }
}
